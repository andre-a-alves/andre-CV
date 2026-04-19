use std::{fmt, path::PathBuf};

use crate::{
    ports::{DocumentRenderer, OutputWriter, PdfCompiler},
    schema::Document,
    validate::{validate_document, ValidationError},
};

#[derive(Debug, Clone)]
pub struct BuildRequest {
    pub document: Document,
    pub tex_path: PathBuf,
    pub work_dir: PathBuf,
    pub compile_pdf: bool,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BuildOutput {
    pub tex_path: PathBuf,
    pub pdf_path: Option<PathBuf>,
}

#[derive(Debug)]
pub enum BuildError<WriteError, CompileError> {
    Validation(ValidationError),
    Render(crate::render::RenderError),
    Write(WriteError),
    Compile(CompileError),
}

impl<WriteError, CompileError> fmt::Display for BuildError<WriteError, CompileError>
where
    WriteError: fmt::Display,
    CompileError: fmt::Display,
{
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Validation(error) => write!(formatter, "validation failed: {error}"),
            Self::Render(error) => write!(formatter, "render failed: {error}"),
            Self::Write(error) => write!(formatter, "write failed: {error}"),
            Self::Compile(error) => write!(formatter, "compile failed: {error}"),
        }
    }
}

impl<WriteError, CompileError> std::error::Error for BuildError<WriteError, CompileError>
where
    WriteError: fmt::Debug + fmt::Display,
    CompileError: fmt::Debug + fmt::Display,
{
}

pub struct BuildResume<R, W, C> {
    renderer: R,
    writer: W,
    compiler: C,
}

impl<R, W, C> BuildResume<R, W, C> {
    pub fn new(renderer: R, writer: W, compiler: C) -> Self {
        Self {
            renderer,
            writer,
            compiler,
        }
    }
}

impl<R, W, C> BuildResume<R, W, C>
where
    R: DocumentRenderer,
    W: OutputWriter,
    C: PdfCompiler,
{
    pub fn execute(
        &self,
        request: BuildRequest,
    ) -> Result<BuildOutput, BuildError<W::Error, C::Error>> {
        validate_document(&request.document).map_err(BuildError::Validation)?;
        let tex = self
            .renderer
            .render(&request.document)
            .map_err(BuildError::Render)?;
        self.writer
            .write_text(&request.tex_path, &tex)
            .map_err(BuildError::Write)?;

        let pdf_path = if request.compile_pdf {
            Some(
                self.compiler
                    .compile(&request.tex_path, &request.work_dir)
                    .map_err(BuildError::Compile)?,
            )
        } else {
            None
        };

        Ok(BuildOutput {
            tex_path: request.tex_path,
            pdf_path,
        })
    }
}
