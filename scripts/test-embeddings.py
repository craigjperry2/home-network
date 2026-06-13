#!/usr/bin/env python3
# /// script
# dependencies = [
#   "httpx",
#   "rich",
# ]
# ///

import httpx
import sys
from rich.console import Console
from rich.panel import Panel

console = Console()


def test_embeddings(text: str, host: str = "localhost", port: int = 11434):
    """
    Tests the embeddings model by sending a POST request to the llama-server.
    Assumes the server is running and exposing an OpenAI-compatible /v1/embeddings endpoint.
    """
    url = f"http://{host}:{port}/v1/embeddings"
    console.print(f"[bold blue]Testing embeddings model at {url}...[/bold blue]")

    payload = {"input": text, "model": "qwen-embed"}

    try:
        with httpx.Client() as client:
            response = client.post(url, json=payload, timeout=60.0)
            response.raise_for_status()
            data = response.json()

            # llama-server returns OpenAI format
            if "data" in data and len(data["data"]) > 0:
                embedding = data["data"][0]["embedding"]
                dim = len(embedding)

                console.print(
                    Panel(
                        f"Text: [italic]{text}[/italic]\n\n"
                        f"Dimensions: [bold green]{dim}[/bold green]\n"
                        f"First 5 values: {embedding[:5]}...",
                        title="[bold green]Embedding Success[/bold green]",
                        border_style="green",
                    )
                )
            else:
                console.print(
                    f"[bold yellow]Warning:[/bold yellow] Unexpected response format: {data}"
                )

    except httpx.ConnectError:
        console.print(
            f"\n[bold red]Connection Error:[/bold red] Could not connect to {url}."
        )
        console.print("\n[bold]Troubleshooting:[/bold]")
        console.print("1. Is the model service running on host 's1'?")
        console.print("   [dim]Check with: systemctl status llama-cpp-qwen-embed[/dim]")
        console.print(f"2. If running on 's1', ensure it's listening on {host}:{port}.")
        console.print(
            "3. If testing from another machine, check firewall and 'llamaCppPort' in nix config."
        )
    except Exception as e:
        console.print(f"[bold red]Error:[/bold red] {e}")
        if hasattr(e, "response") and e.response:
            console.print(f"Response status: {e.response.status_code}")
            console.print(f"Response content: {e.response.text}")


if __name__ == "__main__":
    test_text = "The universe is a grand book which cannot be read until one first learns to comprehend the language and become familiar with the characters in which it is composed."

    if len(sys.argv) > 1:
        test_text = " ".join(sys.argv[1:])

    test_embeddings(test_text)
