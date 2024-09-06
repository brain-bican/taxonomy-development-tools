# Generating Taxonomy Github Pages

_This feature is supported on TDT versions >= 1.0.7. Please consider upgrading your project through following the [upgrade guide](Upgrade.md)_

The Taxonomy Development Tools (TDT) provides a feature to generate a GitHub Pages site for your taxonomy. This feature allows you to create a user-friendly interface for your taxonomy, making it easier for users to explore and understand the data. 

These pages also works in synergy with the [PURL](https://purl.brain-bican.org/) system, allowing you to create a permanent URL for your taxonomy and cell sets.

To generate the GitHub Pages for your taxonomy, follow these steps:

1- In the TDT UI run Actions > Generate > Github Pages

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/docs_menu.png" alt="Documentation generation action." width="300"/>
</p>

This operation will generate documentation on your project root directory under the `docs` folder and push them to the GitHub.

2- (This step only needed once, at the first publishing of the GH pages) Navigate to your GitHub repository and go to the `Settings` tab.

On the left panel select `Pages` and under the `Code and Automation` section. Then select the `gh-pages` branch in the `Branch` section and `Save`.

<p align="center">
    <img src="https://raw.githubusercontent.com/brain-bican/taxonomy-development-tools/main/docs/images/screenshots/docs_config.png" alt="GH Pages configuration" width="500"/>
</p>

Then please wait for a few minutes for the GitHub Pages to be generated. In the background a GitHub action is preparing that branch for you. Then your taxonomy will be available at `https://brain-bican.github.io/<your_repository_name>/`.

## Troubleshooting

If you cannot see the `gh_pages` branch to select at step 2, you may need to wait a few minutes for the GitHub Pages to be generated. In the background a GitHub action is preparing that branch for you.

If the branch is still not visible, please navigate to the `Actions` tab in your repository and check the status of the `Publish mkdocs documentation` action. If it is still running, please wait for it to complete (depending on the size of your taxonomy it may take up to 30 minutes). If the action is failed please [report an issue](https://github.com/brain-bican/taxonomy-development-tools/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=) on the TDT repository. Please add the failed steps logs to the issue for the swift resolution.