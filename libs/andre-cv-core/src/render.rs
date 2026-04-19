use std::fmt;

use crate::{
    ports::DocumentRenderer,
    schema::{Document, Entry, Item, PersonalDetails, Section},
};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RenderError {
    message: String,
}

impl RenderError {
    pub fn new(message: impl Into<String>) -> Self {
        Self {
            message: message.into(),
        }
    }
}

impl fmt::Display for RenderError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(&self.message)
    }
}

impl std::error::Error for RenderError {}

#[derive(Debug, Default, Clone, Copy)]
pub struct LatexRenderer;

impl LatexRenderer {
    pub fn new() -> Self {
        Self
    }
}

impl DocumentRenderer for LatexRenderer {
    fn render(&self, document: &Document) -> Result<String, RenderError> {
        let mut output = String::new();

        push_line(
            &mut output,
            &format!(
                "\\documentclass[theme={},{}]{{andre-cv}}",
                document.options.theme, document.options.font_size
            ),
        );
        output.push('\n');
        push_line(
            &mut output,
            &format!("\\setmainfont{{{}}}", escape_latex(&document.font.main)),
        );
        push_line(
            &mut output,
            &format!("\\setsansfont{{{}}}", escape_latex(&document.font.sans)),
        );
        push_line(
            &mut output,
            &format!("\\setmonofont{{{}}}", escape_latex(&document.font.mono)),
        );
        output.push('\n');
        render_personal_details(&mut output, &document.personal);
        output.push('\n');
        push_line(&mut output, "\\begin{document}");
        render_header(&mut output, document);
        output.push('\n');
        for section in &document.sections {
            render_section(&mut output, section);
            output.push('\n');
        }
        push_line(&mut output, "\\end{document}");

        Ok(output)
    }
}

fn render_personal_details(output: &mut String, personal: &PersonalDetails) {
    push_command(output, "SetName", &personal.name);
    push_optional_command(output, "SetAddressOne", personal.address_one.as_deref());
    push_optional_command(output, "SetAddressTwo", personal.address_two.as_deref());
    push_optional_command(output, "SetAddressThree", personal.address_three.as_deref());
    push_optional_command(output, "SetTown", personal.town.as_deref());
    push_optional_command(output, "SetPhone", personal.phone.as_deref());
    push_optional_command(output, "SetEmail", personal.email.as_deref());
    push_optional_command(output, "SetCitizenship", personal.citizenship.as_deref());
    push_optional_command(output, "SetGithub", personal.github.as_deref());
    push_optional_command(output, "SetLinkedIn", personal.linkedin.as_deref());
    push_optional_command(output, "SetXing", personal.xing.as_deref());
    push_optional_command(output, "SetHomepage", personal.homepage.as_deref());
}

fn render_header(output: &mut String, document: &Document) {
    match document.header.image.as_deref() {
        Some(image) => push_line(
            output,
            &format!(
                "\\DisplayHeader{{{}}}{{{}}}",
                escape_latex(&document.header.subtitle),
                escape_latex_path(image)
            ),
        ),
        None => push_command(output, "DisplayHeader", &document.header.subtitle),
    }
}

fn render_section(output: &mut String, section: &Section) {
    match section {
        Section::Summary { title, body } => {
            push_command(output, "section", title);
            push_line(output, &escape_latex(body));
        }
        Section::Entries { title, entries } => {
            push_command(output, "section", title);
            for entry in entries {
                render_entry(output, entry);
            }
        }
        Section::Items { title, items } => {
            push_command(output, "section", title);
            for item in items {
                render_item(output, item);
            }
        }
    }
}

fn render_entry(output: &mut String, entry: &Entry) {
    push_line(output, "\\cventry[");
    push_key_value(output, "dates", entry.dates.as_deref().unwrap_or_default());
    push_key_value(output, "title", &entry.title);
    push_key_value(output, "org", entry.org.as_deref().unwrap_or_default());
    push_key_value(
        output,
        "location",
        entry.location.as_deref().unwrap_or_default(),
    );
    if let Some(url) = entry.url.as_deref() {
        push_key_value(output, "url", url);
    }
    push_line(output, "]{\\cvitemize{");
    for bullet in &entry.bullets {
        push_line(output, &format!("\t\\item {}", escape_latex(bullet)));
    }
    push_line(output, "}}");
}

fn render_item(output: &mut String, item: &Item) {
    push_line(
        output,
        &format!(
            "\\cvitem{{{}}}{{{}}}",
            escape_latex(&item.label),
            escape_latex(&item.value)
        ),
    );
}

fn push_key_value(output: &mut String, key: &str, value: &str) {
    push_line(output, &format!("\t{key} = {{{}}},", escape_latex(value)));
}

fn push_optional_command(output: &mut String, command: &str, value: Option<&str>) {
    if let Some(value) = value {
        if !value.trim().is_empty() {
            push_command(output, command, value);
        }
    }
}

fn push_command(output: &mut String, command: &str, value: &str) {
    push_line(output, &format!("\\{command}{{{}}}", escape_latex(value)));
}

fn push_line(output: &mut String, line: &str) {
    output.push_str(line);
    output.push('\n');
}

pub fn escape_latex(value: &str) -> String {
    let mut escaped = String::new();
    for character in value.chars() {
        match character {
            '\\' => escaped.push_str("\\textbackslash{}"),
            '&' => escaped.push_str("\\&"),
            '%' => escaped.push_str("\\%"),
            '$' => escaped.push_str("\\$"),
            '#' => escaped.push_str("\\#"),
            '_' => escaped.push_str("\\_"),
            '{' => escaped.push_str("\\{"),
            '}' => escaped.push_str("\\}"),
            '~' => escaped.push_str("\\textasciitilde{}"),
            '^' => escaped.push_str("\\textasciicircum{}"),
            _ => escaped.push(character),
        }
    }
    escaped
}

fn escape_latex_path(value: &str) -> String {
    value.replace('\\', "/").replace(' ', "\\space ")
}

#[cfg(test)]
mod tests {
    use crate::{
        ports::DocumentRenderer,
        schema::{
            Document, DocumentOptions, Entry, FontConfig, Header, PersonalDetails, Section, Theme,
        },
    };

    use super::{escape_latex, LatexRenderer};

    #[test]
    fn escapes_latex_special_characters() {
        assert_eq!(
            escape_latex(r#"\&%$#_{}~^"#),
            r#"\textbackslash{}\&\%\$\#\_\{\}\textasciitilde{}\textasciicircum{}"#
        );
    }

    #[test]
    fn renders_entries_and_items() {
        let document = Document {
            options: DocumentOptions {
                theme: Theme::ModernResume,
                font_size: "10pt".to_string(),
            },
            font: FontConfig::default(),
            personal: PersonalDetails {
                name: "Dr. Henry Jones, Jr.".to_string(),
                address_one: None,
                address_two: None,
                address_three: None,
                town: Some("Bedford".to_string()),
                phone: None,
                email: Some("indy@example.com".to_string()),
                citizenship: None,
                github: None,
                linkedin: None,
                xing: None,
                homepage: None,
            },
            header: Header {
                subtitle: "Archaeologist".to_string(),
                image: None,
            },
            sections: vec![
                Section::Entries {
                    title: "Experience".to_string(),
                    entries: vec![Entry {
                        dates: Some("1936 - Present".to_string()),
                        title: "Professor".to_string(),
                        org: Some("Marshall College".to_string()),
                        location: Some("Bedford".to_string()),
                        url: None,
                        bullets: vec!["Lectures on archaeology.".to_string()],
                    }],
                },
                Section::Items {
                    title: "Skills".to_string(),
                    items: vec![crate::schema::Item {
                        label: "Languages".to_string(),
                        value: "English, German".to_string(),
                    }],
                },
            ],
        };

        let tex = LatexRenderer::new().render(&document).unwrap();
        assert!(tex.contains("\\documentclass[theme=modern-resume,10pt]{andre-cv}"));
        assert!(tex.contains("\\cventry["));
        assert!(tex.contains("\\cvitem{Languages}{English, German}"));
    }
}
