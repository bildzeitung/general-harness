import typer

app = typer.Typer()


@app.command()
def main() -> None:
    """{{PROJECTNAME}}"""
    typer.echo("Hello from {{PROJECTNAME}}")


if __name__ == "__main__":
    app()
