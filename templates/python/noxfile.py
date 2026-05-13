import nox

nox.options.reuse_existing_virtualenvs = True


@nox.session
def tests(session: nox.Session) -> None:
    session.install("-e", ".[dev]")
    session.run("pytest", "tests/", "--tb=short")


@nox.session
def ruff(session: nox.Session) -> None:
    session.install("ruff")
    session.run("ruff", "check", "src/", "tests/")
    session.run("ruff", "format", "--check", "src/", "tests/")


@nox.session
def typecheck(session: nox.Session) -> None:
    session.install("-e", ".[dev]")
    session.run("ty", "check", "src/")
