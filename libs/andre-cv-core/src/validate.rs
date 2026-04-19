use std::fmt;

use crate::schema::{Document, Section};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ValidationError {
    messages: Vec<String>,
}

impl ValidationError {
    pub fn new(messages: Vec<String>) -> Self {
        Self { messages }
    }

    pub fn messages(&self) -> &[String] {
        &self.messages
    }
}

impl fmt::Display for ValidationError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(formatter, "{}", self.messages.join("; "))
    }
}

impl std::error::Error for ValidationError {}

pub fn validate_document(document: &Document) -> Result<(), ValidationError> {
    let mut messages = Vec::new();

    if document.personal.name.trim().is_empty() {
        messages.push("personal.name is required".to_string());
    }

    if document.header.subtitle.trim().is_empty() {
        messages.push("header.subtitle is required".to_string());
    }

    if document.sections.is_empty() {
        messages.push("at least one section is required".to_string());
    }

    for (section_index, section) in document.sections.iter().enumerate() {
        let section_path = format!("sections[{section_index}]");
        if section.title().trim().is_empty() {
            messages.push(format!("{section_path}.title is required"));
        }

        match section {
            Section::Summary { body, .. } if body.trim().is_empty() => {
                messages.push(format!("{section_path}.body is required"));
            }
            Section::Entries { entries, .. } => {
                if entries.is_empty() {
                    messages.push(format!("{section_path}.entries must not be empty"));
                }
                for (entry_index, entry) in entries.iter().enumerate() {
                    let entry_path = format!("{section_path}.entries[{entry_index}]");
                    if entry.title.trim().is_empty() {
                        messages.push(format!("{entry_path}.title is required"));
                    }
                    if entry.bullets.iter().any(|bullet| bullet.trim().is_empty()) {
                        messages.push(format!(
                            "{entry_path}.bullets must not contain empty values"
                        ));
                    }
                }
            }
            Section::Items { items, .. } => {
                if items.is_empty() {
                    messages.push(format!("{section_path}.items must not be empty"));
                }
                for (item_index, item) in items.iter().enumerate() {
                    let item_path = format!("{section_path}.items[{item_index}]");
                    if item.label.trim().is_empty() {
                        messages.push(format!("{item_path}.label is required"));
                    }
                    if item.value.trim().is_empty() {
                        messages.push(format!("{item_path}.value is required"));
                    }
                }
            }
            _ => {}
        }
    }

    if messages.is_empty() {
        Ok(())
    } else {
        Err(ValidationError::new(messages))
    }
}

#[cfg(test)]
mod tests {
    use crate::schema::{
        Document, DocumentOptions, FontConfig, Header, PersonalDetails, Section, Theme,
    };

    use super::validate_document;

    #[test]
    fn rejects_missing_name() {
        let document = Document {
            options: DocumentOptions {
                theme: Theme::ModernResume,
                font_size: "10pt".to_string(),
            },
            font: FontConfig::default(),
            personal: PersonalDetails {
                name: String::new(),
                address_one: None,
                address_two: None,
                address_three: None,
                town: None,
                phone: None,
                email: None,
                citizenship: None,
                github: None,
                linkedin: None,
                xing: None,
                homepage: None,
            },
            header: Header {
                subtitle: "Engineer".to_string(),
                image: None,
            },
            sections: vec![Section::Summary {
                title: "Summary".to_string(),
                body: "Builds things.".to_string(),
            }],
        };

        let error = validate_document(&document).unwrap_err();
        assert!(error.to_string().contains("personal.name is required"));
    }
}
