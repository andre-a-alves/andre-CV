use std::path::{Path, PathBuf};

use crate::{render::RenderError, schema::Document};

pub trait InputReader {
    type Error;

    fn read(&self) -> Result<Document, Self::Error>;
}

pub trait DocumentRenderer {
    fn render(&self, document: &Document) -> Result<String, RenderError>;
}

pub trait OutputWriter {
    type Error;

    fn write_text(&self, path: &Path, contents: &str) -> Result<(), Self::Error>;
}

pub trait PdfCompiler {
    type Error;

    fn compile(&self, tex_path: &Path, work_dir: &Path) -> Result<PathBuf, Self::Error>;
}
