# Updating the TDT

Stay up-to-date with the latest version of the Taxonomy Development Tools (TDT) by following these steps:

## Step 1: Secure Your Work
**Before updating**, ensure all your work is saved and committed to the repository.
- Commit and push any pending changes. Use the TDT interface (`Actions` > `File` > `Save`) for this purpose.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/actions_file_save.png" alt="Save your progress" width="300"/>
</p>

## Step 2: Upgrade to the Latest Version
Update TDT by pulling the latest Docker image. In the root directory of your project, execute the following command in a terminal:

```bash
make pull_tdt
```

**Note:** This operation will kill the running TDT container and update it with the latest version.

## Step 3: Synchronize Your Work

If your administrator has updated the taxonomy repository, you need to synchronize your work with the latest changes.

**For automatic updates:**

If your system is set to automatically sync, it will do so when you start TDT.

**For manual updates:**

If automatic sync is not enabled, manually pull changes by running these commands in your project's root directory:

```bash
git pull
bash run.sh make clean
```

or you can delete your project and clone it again.

## Step 4: Administrator Updates

**If you're managing the taxonomy repository:**

Update the repository with the following command in the root directory:

```bash
bash run.sh make upgrade
```

After upgrading, launch TDT, review the changes, and save them if they meet your expectations (`Actions` > `File` > `Save`). Inform your team about the updates and guide them through the update process as described in Steps 1-3.

## Encountering Issues?

If you run into any problems during the update process, please [report an issue](https://github.com/brain-bican/taxonomy-development-tools/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=) on the TDT repository with a detailed description of the problem. Our team will assist you in resolving the issue and ensure a smooth update process.


