
# Build Instructions
First, change the version number in pubspec.yaml. Then build and run:

```bash
flutter run -d macos
```

# Release Instructions
Option 1:
- Run manual action in Github
- Rename the release it generates

Option 2:
Create the tag locally
```bash
git tag 1.0.2
```
Push the tag (this triggers the workflow)
```bash
git push origin 1.0.2
```