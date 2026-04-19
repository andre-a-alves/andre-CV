use std::{fmt, str::FromStr};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Document {
    pub options: DocumentOptions,
    pub font: FontConfig,
    pub personal: PersonalDetails,
    pub header: Header,
    pub sections: Vec<Section>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DocumentOptions {
    pub theme: Theme,
    pub font_size: String,
}

impl Default for DocumentOptions {
    fn default() -> Self {
        Self {
            theme: Theme::ModernResume,
            font_size: "10pt".to_string(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct FontConfig {
    pub main: String,
    pub sans: String,
    pub mono: String,
}

impl Default for FontConfig {
    fn default() -> Self {
        Self {
            main: "Source Sans 3".to_string(),
            sans: "Source Sans 3".to_string(),
            mono: "Source Sans 3".to_string(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PersonalDetails {
    pub name: String,
    pub address_one: Option<String>,
    pub address_two: Option<String>,
    pub address_three: Option<String>,
    pub town: Option<String>,
    pub phone: Option<String>,
    pub email: Option<String>,
    pub citizenship: Option<String>,
    pub github: Option<String>,
    pub linkedin: Option<String>,
    pub xing: Option<String>,
    pub homepage: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Header {
    pub subtitle: String,
    pub image: Option<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Section {
    Summary { title: String, body: String },
    Entries { title: String, entries: Vec<Entry> },
    Items { title: String, items: Vec<Item> },
}

impl Section {
    pub fn title(&self) -> &str {
        match self {
            Self::Summary { title, .. }
            | Self::Entries { title, .. }
            | Self::Items { title, .. } => title,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Entry {
    pub dates: Option<String>,
    pub title: String,
    pub org: Option<String>,
    pub location: Option<String>,
    pub url: Option<String>,
    pub bullets: Vec<String>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Item {
    pub label: String,
    pub value: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Theme {
    ClassicResume,
    ModernResume,
    TabularCv,
}

impl Theme {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::ClassicResume => "classic-resume",
            Self::ModernResume => "modern-resume",
            Self::TabularCv => "tabular-cv",
        }
    }
}

impl fmt::Display for Theme {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(self.as_str())
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ThemeParseError {
    value: String,
}

impl ThemeParseError {
    pub fn new(value: impl Into<String>) -> Self {
        Self {
            value: value.into(),
        }
    }
}

impl fmt::Display for ThemeParseError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            formatter,
            "unknown theme '{}'; expected classic-resume, modern-resume, or tabular-cv",
            self.value
        )
    }
}

impl std::error::Error for ThemeParseError {}

impl FromStr for Theme {
    type Err = ThemeParseError;

    fn from_str(value: &str) -> Result<Self, Self::Err> {
        match value {
            "classic-resume" => Ok(Self::ClassicResume),
            "modern-resume" => Ok(Self::ModernResume),
            "tabular-cv" => Ok(Self::TabularCv),
            other => Err(ThemeParseError::new(other)),
        }
    }
}
