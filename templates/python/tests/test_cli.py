from typer.testing import CliRunner

from {{PROJECTNAME}}.__main__ import app

runner = CliRunner()


def test_main() -> None:
    result = runner.invoke(app, [])
    assert result.exit_code == 0
