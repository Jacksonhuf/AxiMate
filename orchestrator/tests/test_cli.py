from aximate_orchestrator.cli import main


def test_version_exits_zero() -> None:
    assert main(["--version"]) == 0
