# Collaborative working with TDT
The Taxonomy Development Tools (TDT) platform is designed to facilitate collaborative working on taxonomy projects. This guide explains how to work with TDT in a team environment, including how to save, share, and review annotations.

TDT is not an online tool, but a local application that runs on your machine. To collaborate with others, TDT use a version control system (Git) and a remote repository on GitHub in the background. This way, you can share your work with others, review their annotations, and keep track of changes.

## Saving Your Work

You can use the TDT interface to save your work at any time. To save your progress, use action `Actions > File > Save`. 

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/actions_file_save.png" alt="Save your progress" width="300"/>
</p>

This action will:
- Save your progress to the local filesystem _(local files can be found at `curation_tables` directory)_.
- Gets the latest changes from the remote repository.
- Automatically merges the changes with your local changes.
- If there are any conflicts that couldn't be automatically resolved, you will be prompted to resolve them. Please see [Manually Resolve Conflicts](#manually-resolve-coonflicts)
- Pushes the merged changes to the remote repository.

## Manually Resolve Conflicts

In some cases git may not be able to automatically resolve conflicts. If this happens, you will need to manually resolve the conflicts. TDT will provide you the list of files that have conflicts. You can use any text editor to resolve the conflicts. Once you have resolved the conflicts, you can re-run `Actions > File > Save` to push the changes to the remote repository.

Git highlights the conflicts in the files with the `<<<<<<<` and `>>>>>>>` markers. For example:

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/conflict.png" alt="Git conflict" width="300"/>
</p>

In this example the conflict is in the annotation of `Mono_3`. Section starting with `<<<<<<< HEAD` to `=======` is the remote version of the file, and the section starting with `=======` to `>>>>>>>` is the local version of the file. You need to resolve the conflict by choosing which version to keep or by combining the two versions.

Once you have resolved the conflicts manually (there are no `<<<<<<<`, `=======` and `>>>>>>>` tagged lines in the file), you can re-run `Actions > File > Save` to push the changes to the remote repository.