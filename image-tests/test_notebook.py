#!/usr/bin/env python3
import copy
import nbformat
import os
from nbclient import NotebookClient
from pathlib import Path


labs = [
    "Hawthorne_test.ipynb",
    "all_hub_basic_notebook.ipynb",
    "lec01_executed_1.ipynb",
]


def clean_notebook_metadata(notebook):
    """
    Cleans the execution-specific metadata and execution counts from a notebook.

    This is crucial for ensuring that the notebook files remain clean for version
    control systems like Git, preventing unnecessary diffs after each run.

    Args:
        notebook (nbformat.NotebookNode): The executed notebook object.

    Returns:
        nbformat.NotebookNode: A new notebook object with cleaned metadata.
    """
    cleaned_notebook = copy.deepcopy(notebook)

    # Remove the top-level 'metadata.execution' field if it exists.
    # This field is added by nbclient during execution.
    if "execution" in cleaned_notebook.metadata:
        del cleaned_notebook.metadata["execution"]

    for cell in cleaned_notebook.cells:
        # Reset execution_count for all code cells. This removes the
        # sequential numbering (e.g., [1], [2]) from the cells.
        if cell.cell_type == "code":
            cell["execution_count"] = None

        # Clean cell-level metadata, for example, the 'metadata.execution' in some versions.
        if "metadata" in cell and "execution" in cell.metadata:
            del cell.metadata["execution"]

    return cleaned_notebook


def run_notebook(notebook, timeout=600):
    """
    Executes all cells in a Jupyter notebook and saves the output back to the same file.

    It uses `nbclient` to execute the notebook and then calls `clean_notebook_metadata`
    to remove execution-specific information before saving.

    Args:
        notebook_path (str): The path to the notebook file to execute.
        timeout (int, optional): The maximum time in seconds to wait for
                                 a single cell to execute. Defaults to 600.

    Returns:
        bool: True if the notebook executed successfully, False otherwise.
    """
    notebook_path = os.path.join("notebooks", notebook)

    try:
        notebook = nbformat.read(notebook_path, as_version=4)
    except FileNotFoundError:
        return False

    client = NotebookClient(
        notebook,
        timeout=600,
        kernel_name="python3",
        # This resource is used to set the working directory for the notebook's kernel.
        # It ensures that relative paths within the notebook resolve correctly.
        resources={"metadata": {"path": str(Path(notebook_path).parent)}},
    )

    try:
        # Execute the notebook. This is the core step where all cells are run.
        executed_notebook = client.execute()
        # Clean the metadata before saving to keep the file tidy.
        executed_notebook = clean_notebook_metadata(executed_notebook)
    except Exception:
        return False

    # Save the executed and cleaned notebook back to the original file path.
    with open(notebook_path, "w", encoding="utf-8") as f:
        nbformat.write(executed_notebook, f)

    return True


def test_hawthorne_notebook_execution():
    assert run_notebook("Hawthorne_test.ipynb", True)


def test_all_hub_basic_notebook_execution():
    assert run_notebook("all_hub_basic_notebook.ipynb", True)


def test_lec01_executed_1_notebook_execution():
    assert run_notebook("lec01_executed_1.ipynb", True)


if __name__ == "__main__":
    test_hawthorne_notebook_execution()
    test_all_hub_basic_notebook_execution()
    test_lec01_executed_1_notebook_execution()
