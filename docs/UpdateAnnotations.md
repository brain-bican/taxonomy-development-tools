# Programmatically Update Annotations

This guide explains how to programmatically update annotations and reload the TDT interface to reflect those changes. This feature is useful for batch updates and can be executed using the [cas-tools Python package](https://pypi.org/project/cas-tools/).

## Step 1: Save your progress

Before updating annotations programmatically (this will take place outside of TDT), ensure all your work is saved and committed to the repository. Use the TDT interface to save your progress as a CAS json file (`Actions` > `Export` > `To CAS`) and push it (`Actions` > `File` > `Save`) to your GitHub repository.

## Step 2: Programmatically update annotations

CAS json is a plain json file you can edit with any tool you like.

The [cas-tools Python package](https://pypi.org/project/cas-tools/) facilitates easier programmatic updates to annotations. Please check the cas-tools [example notebooks](https://github.com/cellannotation/cas-tools/blob/main/notebooks/add_author_annotations.ipynb) for detailed instructions on using the package to batch add or update annotations.

## Step 3: Reload TDT

After programmatically updating annotations, reload the TDT interface to reflect the changes. Follow these steps:

1. Place the updated CAS json file in the `input_data` directory of your project. Remove any other files in the directory, except `README.md`.
2. Load the new data into TDT by running the following command in the root directory of your project:

```bash
bash run.sh make reload_data
```

3. Start TDT as usual to see the updated annotations in the interface:
    
```bash
bash run.sh make serve
```
