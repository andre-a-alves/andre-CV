use std::{
    env,
    ffi::OsStr,
    fmt, fs,
    path::{Path, PathBuf},
    process::{Command, ExitCode},
    str::FromStr,
};

use andre_cv_core::{
    BuildRequest, BuildResume, Document, DocumentOptions, Entry, FontConfig, Header, InputReader,
    Item, LatexRenderer, OutputWriter, PdfCompiler, PersonalDetails, Section, Theme,
};
use serde::Deserialize;

fn main() -> ExitCode {
    match run(env::args().skip(1).collect()) {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run(args: Vec<String>) -> Result<(), CliError> {
    let command = CliCommand::parse(args)?;
    match command {
        CliCommand::Help => {
            print_help();
            Ok(())
        }
        CliCommand::Build(options) => build(options),
    }
}

fn build(options: BuildOptions) -> Result<(), CliError> {
    let input_path = options
        .input
        .canonicalize()
        .map_err(|source| CliError::IoWithPath {
            path: options.input.clone(),
            source,
        })?;
    let input_dir = input_path.parent().unwrap_or_else(|| Path::new("."));
    let output_dir = options.output_dir;
    fs::create_dir_all(&output_dir).map_err(|source| CliError::IoWithPath {
        path: output_dir.clone(),
        source,
    })?;

    let output_name = options
        .name
        .unwrap_or_else(|| input_stem(&input_path).unwrap_or_else(|| "resume".to_string()));
    let build_dir = output_dir.join(".andre-cv-build").join(&output_name);
    if build_dir.exists() {
        fs::remove_dir_all(&build_dir).map_err(|source| CliError::IoWithPath {
            path: build_dir.clone(),
            source,
        })?;
    }
    fs::create_dir_all(&build_dir).map_err(|source| CliError::IoWithPath {
        path: build_dir.clone(),
        source,
    })?;

    write_latex_assets(&build_dir)?;

    let reader = YamlFileReader {
        input_path: input_path.clone(),
        input_dir: input_dir.to_path_buf(),
        build_dir: build_dir.clone(),
        theme_override: options.theme_override,
    };
    let document = reader.read()?;

    let tex_path = build_dir.join(format!("{output_name}.tex"));
    let use_case = BuildResume::new(LatexRenderer::new(), FsWriter, LuaLatexCompiler);
    let result = use_case.execute(BuildRequest {
        document,
        tex_path: tex_path.clone(),
        work_dir: build_dir.clone(),
        compile_pdf: !options.tex_only,
    })?;

    let final_tex_path = output_dir.join(format!("{output_name}.tex"));
    fs::copy(&result.tex_path, &final_tex_path).map_err(|source| CliError::IoWithPath {
        path: final_tex_path.clone(),
        source,
    })?;
    let build_assets_dir = build_dir.join("assets");
    if build_assets_dir.exists() {
        copy_dir_all(&build_assets_dir, &output_dir.join("assets"))?;
    }

    if let Some(pdf_path) = result.pdf_path {
        let final_pdf_path = output_dir.join(format!("{output_name}.pdf"));
        fs::copy(&pdf_path, &final_pdf_path).map_err(|source| CliError::IoWithPath {
            path: final_pdf_path.clone(),
            source,
        })?;
        println!("wrote {}", final_pdf_path.display());
    }
    println!("wrote {}", final_tex_path.display());

    if !options.keep_build_dir {
        fs::remove_dir_all(&build_dir).map_err(|source| CliError::IoWithPath {
            path: build_dir,
            source,
        })?;
    }

    Ok(())
}

#[derive(Debug)]
enum CliCommand {
    Build(BuildOptions),
    Help,
}

impl CliCommand {
    fn parse(args: Vec<String>) -> Result<Self, CliError> {
        if args.is_empty() || args.iter().any(|arg| arg == "-h" || arg == "--help") {
            return Ok(Self::Help);
        }

        let mut args = args.into_iter();
        let command = args.next().unwrap();
        match command.as_str() {
            "build" => Ok(Self::Build(BuildOptions::parse(args.collect())?)),
            other => Err(CliError::InvalidArgs(format!(
                "unknown command '{other}'; expected 'build'"
            ))),
        }
    }
}

#[derive(Debug)]
struct BuildOptions {
    input: PathBuf,
    output_dir: PathBuf,
    name: Option<String>,
    theme_override: Option<Theme>,
    tex_only: bool,
    keep_build_dir: bool,
}

impl BuildOptions {
    fn parse(args: Vec<String>) -> Result<Self, CliError> {
        let mut input = None;
        let mut output_dir = PathBuf::from("out");
        let mut name = None;
        let mut theme_override = None;
        let mut tex_only = false;
        let mut keep_build_dir = false;
        let mut index = 0;

        while index < args.len() {
            match args[index].as_str() {
                "--output-dir" => {
                    index += 1;
                    output_dir = PathBuf::from(required_value(&args, index, "--output-dir")?);
                }
                "--name" => {
                    index += 1;
                    name = Some(required_value(&args, index, "--name")?.to_string());
                }
                "--theme" => {
                    index += 1;
                    let value = required_value(&args, index, "--theme")?;
                    theme_override = Some(Theme::from_str(value).map_err(CliError::Theme)?);
                }
                "--tex-only" => tex_only = true,
                "--keep-build-dir" => keep_build_dir = true,
                value if value.starts_with('-') => {
                    return Err(CliError::InvalidArgs(format!("unknown flag '{value}'")));
                }
                value => {
                    if input.replace(PathBuf::from(value)).is_some() {
                        return Err(CliError::InvalidArgs(
                            "only one input YAML file can be provided".to_string(),
                        ));
                    }
                }
            }
            index += 1;
        }

        Ok(Self {
            input: input.ok_or_else(|| {
                CliError::InvalidArgs(
                    "missing input YAML file: andre-cv build input.yml".to_string(),
                )
            })?,
            output_dir,
            name,
            theme_override,
            tex_only,
            keep_build_dir,
        })
    }
}

fn required_value<'a>(args: &'a [String], index: usize, flag: &str) -> Result<&'a str, CliError> {
    args.get(index)
        .map(String::as_str)
        .filter(|value| !value.starts_with('-'))
        .ok_or_else(|| CliError::InvalidArgs(format!("{flag} requires a value")))
}

fn print_help() {
    println!(
        "andre-cv\n\nUSAGE:\n    andre-cv build <input.yml> [--output-dir <dir>] [--name <name>] [--theme <theme>] [--tex-only] [--keep-build-dir]\n\nTHEMES:\n    classic-resume\n    modern-resume\n    tabular-cv"
    );
}

#[derive(Debug, Deserialize)]
struct YamlDocument {
    theme: Option<String>,
    font: Option<YamlFont>,
    personal: YamlPersonal,
    header: YamlHeader,
    #[serde(default)]
    sections: Vec<YamlSection>,
}

#[derive(Debug)]
struct YamlFileReader {
    input_path: PathBuf,
    input_dir: PathBuf,
    build_dir: PathBuf,
    theme_override: Option<Theme>,
}

impl InputReader for YamlFileReader {
    type Error = CliError;

    fn read(&self) -> Result<Document, Self::Error> {
        let yaml = fs::read_to_string(&self.input_path).map_err(|source| CliError::IoWithPath {
            path: self.input_path.clone(),
            source,
        })?;
        let dto: YamlDocument = serde_yaml::from_str(&yaml).map_err(CliError::Yaml)?;
        dto.into_document(self.theme_override, &self.input_dir, &self.build_dir)
    }
}

impl YamlDocument {
    fn into_document(
        self,
        theme_override: Option<Theme>,
        input_dir: &Path,
        build_dir: &Path,
    ) -> Result<Document, CliError> {
        let theme = match theme_override {
            Some(theme) => theme,
            None => self
                .theme
                .as_deref()
                .map(Theme::from_str)
                .transpose()
                .map_err(CliError::Theme)?
                .unwrap_or(Theme::ModernResume),
        };
        let header_image = match self.header.image {
            Some(image) => Some(copy_asset(input_dir, build_dir, &image)?),
            None => None,
        };

        Ok(Document {
            options: DocumentOptions {
                theme,
                font_size: "10pt".to_string(),
            },
            font: self.font.unwrap_or_default().into(),
            personal: self.personal.into(),
            header: Header {
                subtitle: self.header.subtitle,
                image: header_image,
            },
            sections: self
                .sections
                .into_iter()
                .map(YamlSection::into_section)
                .collect::<Result<Vec<_>, _>>()?,
        })
    }
}

#[derive(Debug, Default, Deserialize)]
struct YamlFont {
    main: Option<String>,
    sans: Option<String>,
    mono: Option<String>,
}

impl From<YamlFont> for FontConfig {
    fn from(value: YamlFont) -> Self {
        let default = FontConfig::default();
        Self {
            main: value.main.unwrap_or(default.main),
            sans: value.sans.unwrap_or(default.sans),
            mono: value.mono.unwrap_or(default.mono),
        }
    }
}

#[derive(Debug, Deserialize)]
struct YamlPersonal {
    name: String,
    address_one: Option<String>,
    address_two: Option<String>,
    address_three: Option<String>,
    town: Option<String>,
    phone: Option<String>,
    email: Option<String>,
    citizenship: Option<String>,
    github: Option<String>,
    linkedin: Option<String>,
    xing: Option<String>,
    homepage: Option<String>,
}

impl From<YamlPersonal> for PersonalDetails {
    fn from(value: YamlPersonal) -> Self {
        Self {
            name: value.name,
            address_one: value.address_one,
            address_two: value.address_two,
            address_three: value.address_three,
            town: value.town,
            phone: value.phone,
            email: value.email,
            citizenship: value.citizenship,
            github: value.github,
            linkedin: value.linkedin,
            xing: value.xing,
            homepage: value.homepage,
        }
    }
}

#[derive(Debug, Deserialize)]
struct YamlHeader {
    subtitle: String,
    image: Option<String>,
}

#[derive(Debug, Deserialize)]
struct YamlSection {
    #[serde(rename = "type")]
    kind: String,
    title: String,
    body: Option<String>,
    entries: Option<Vec<YamlEntry>>,
    items: Option<Vec<YamlItem>>,
}

impl YamlSection {
    fn into_section(self) -> Result<Section, CliError> {
        match self.kind.as_str() {
            "summary" => Ok(Section::Summary {
                title: self.title,
                body: self.body.unwrap_or_default(),
            }),
            "entries" => Ok(Section::Entries {
                title: self.title,
                entries: self
                    .entries
                    .unwrap_or_default()
                    .into_iter()
                    .map(Into::into)
                    .collect(),
            }),
            "items" => Ok(Section::Items {
                title: self.title,
                items: self
                    .items
                    .unwrap_or_default()
                    .into_iter()
                    .map(Into::into)
                    .collect(),
            }),
            other => Err(CliError::InvalidInput(format!(
                "unknown section type '{other}'; expected summary, entries, or items"
            ))),
        }
    }
}

#[derive(Debug, Deserialize)]
struct YamlEntry {
    dates: Option<String>,
    title: String,
    org: Option<String>,
    location: Option<String>,
    url: Option<String>,
    #[serde(default)]
    bullets: Vec<String>,
}

impl From<YamlEntry> for Entry {
    fn from(value: YamlEntry) -> Self {
        Self {
            dates: value.dates,
            title: value.title,
            org: value.org,
            location: value.location,
            url: value.url,
            bullets: value.bullets,
        }
    }
}

#[derive(Debug, Deserialize)]
struct YamlItem {
    label: String,
    value: String,
}

impl From<YamlItem> for Item {
    fn from(value: YamlItem) -> Self {
        Self {
            label: value.label,
            value: value.value,
        }
    }
}

#[derive(Debug, Clone, Copy)]
struct FsWriter;

impl OutputWriter for FsWriter {
    type Error = CliError;

    fn write_text(&self, path: &Path, contents: &str) -> Result<(), Self::Error> {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).map_err(|source| CliError::IoWithPath {
                path: parent.to_path_buf(),
                source,
            })?;
        }
        fs::write(path, contents).map_err(|source| CliError::IoWithPath {
            path: path.to_path_buf(),
            source,
        })
    }
}

#[derive(Debug, Clone, Copy)]
struct LuaLatexCompiler;

impl PdfCompiler for LuaLatexCompiler {
    type Error = CliError;

    fn compile(&self, tex_path: &Path, work_dir: &Path) -> Result<PathBuf, Self::Error> {
        let file_name = tex_path
            .file_name()
            .and_then(OsStr::to_str)
            .ok_or_else(|| {
                CliError::InvalidInput("TeX path must have a UTF-8 filename".to_string())
            })?;
        let latex_dir = work_dir.join("latex");
        let texinputs = format!("{}//:", latex_dir.display());
        for pass in 1..=2 {
            let output = Command::new("lualatex")
                .arg("-interaction=nonstopmode")
                .arg("-halt-on-error")
                .arg(file_name)
                .current_dir(work_dir)
                .env("TEXINPUTS", &texinputs)
                .output()
                .map_err(|source| CliError::Command {
                    program: "lualatex".to_string(),
                    source,
                })?;

            if !output.status.success() {
                return Err(CliError::LatexFailed {
                    pass,
                    status: output.status.code(),
                    stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
                    stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
                });
            }
        }

        Ok(tex_path.with_extension("pdf"))
    }
}

const LATEX_FILES: &[(&str, &str)] = &[
    ("andre-cv.cls", include_str!("../../../latex/andre-cv.cls")),
    (
        "themes/tabular-cv.sty",
        include_str!("../../../latex/themes/tabular-cv.sty"),
    ),
    (
        "themes/classic-resume.sty",
        include_str!("../../../latex/themes/classic-resume.sty"),
    ),
    (
        "themes/modern-resume.sty",
        include_str!("../../../latex/themes/modern-resume.sty"),
    ),
    (
        "letters/german-din.sty",
        include_str!("../../../latex/letters/german-din.sty"),
    ),
    (
        "letters/us-business.sty",
        include_str!("../../../latex/letters/us-business.sty"),
    ),
];

fn write_latex_assets(build_dir: &Path) -> Result<(), CliError> {
    let latex_dir = build_dir.join("latex");
    for (relative_path, contents) in LATEX_FILES {
        let path = latex_dir.join(relative_path);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).map_err(|source| CliError::IoWithPath {
                path: parent.to_path_buf(),
                source,
            })?;
        }
        fs::write(&path, contents).map_err(|source| CliError::IoWithPath { path, source })?;
    }
    Ok(())
}

fn copy_asset(input_dir: &Path, build_dir: &Path, image: &str) -> Result<String, CliError> {
    let source = input_dir.join(image);
    let file_name = source
        .file_name()
        .and_then(OsStr::to_str)
        .ok_or_else(|| CliError::InvalidInput(format!("asset path '{image}' has no filename")))?
        .to_string();
    let asset_dir = build_dir.join("assets");
    fs::create_dir_all(&asset_dir).map_err(|source| CliError::IoWithPath {
        path: asset_dir.clone(),
        source,
    })?;
    let target = asset_dir.join(&file_name);
    fs::copy(&source, &target).map_err(|source_error| CliError::IoWithPath {
        path: source,
        source: source_error,
    })?;
    Ok(format!("assets/{file_name}"))
}

fn input_stem(input_path: &Path) -> Option<String> {
    input_path
        .file_stem()
        .and_then(OsStr::to_str)
        .map(ToOwned::to_owned)
}

fn copy_dir_all(source: &Path, target: &Path) -> Result<(), CliError> {
    fs::create_dir_all(target).map_err(|source_error| CliError::IoWithPath {
        path: target.to_path_buf(),
        source: source_error,
    })?;
    for entry in fs::read_dir(source).map_err(|source_error| CliError::IoWithPath {
        path: source.to_path_buf(),
        source: source_error,
    })? {
        let entry = entry.map_err(|source_error| CliError::IoWithPath {
            path: source.to_path_buf(),
            source: source_error,
        })?;
        let entry_source = entry.path();
        let entry_target = target.join(entry.file_name());
        if entry_source.is_dir() {
            copy_dir_all(&entry_source, &entry_target)?;
        } else {
            fs::copy(&entry_source, &entry_target).map_err(|source_error| {
                CliError::IoWithPath {
                    path: entry_source,
                    source: source_error,
                }
            })?;
        }
    }
    Ok(())
}

#[derive(Debug)]
enum CliError {
    InvalidArgs(String),
    InvalidInput(String),
    Theme(andre_cv_core::schema::ThemeParseError),
    Yaml(serde_yaml::Error),
    IoWithPath {
        path: PathBuf,
        source: std::io::Error,
    },
    Command {
        program: String,
        source: std::io::Error,
    },
    LatexFailed {
        pass: usize,
        status: Option<i32>,
        stdout: String,
        stderr: String,
    },
    Build(String),
}

impl fmt::Display for CliError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::InvalidArgs(message) | Self::InvalidInput(message) => {
                formatter.write_str(message)
            }
            Self::Theme(error) => write!(formatter, "{error}"),
            Self::Yaml(error) => write!(formatter, "failed to parse YAML: {error}"),
            Self::IoWithPath { path, source } => {
                write!(formatter, "{}: {source}", path.display())
            }
            Self::Command { program, source } => {
                write!(formatter, "failed to run {program}: {source}")
            }
            Self::LatexFailed {
                pass,
                status,
                stdout,
                stderr,
            } => {
                write!(
                    formatter,
                    "lualatex pass {pass} failed with status {:?}\nstdout:\n{}\nstderr:\n{}",
                    status, stdout, stderr
                )
            }
            Self::Build(message) => formatter.write_str(message),
        }
    }
}

impl std::error::Error for CliError {}

impl<W, C> From<andre_cv_core::build::BuildError<W, C>> for CliError
where
    W: fmt::Display,
    C: fmt::Display,
{
    fn from(value: andre_cv_core::build::BuildError<W, C>) -> Self {
        Self::Build(value.to_string())
    }
}

#[cfg(test)]
mod tests {
    use super::{run, CliError};

    #[test]
    fn rejects_unknown_command() {
        let error = run(vec!["nope".to_string()]).unwrap_err();
        assert!(matches!(error, CliError::InvalidArgs(_)));
    }
}
