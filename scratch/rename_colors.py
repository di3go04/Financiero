import os
import re

def replace_colors(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace AppTheme.emerald -> AppTheme.primaryCyan
                new_content = re.sub(r'AppTheme\.emerald', r'AppTheme.primaryCyan', content)
                # Replace AppTheme.indigo -> AppTheme.secondaryBlue
                new_content = re.sub(r'AppTheme\.indigo', r'AppTheme.secondaryBlue', new_content)
                
                # Also replace any stray emerald or indigo that might refer to the theme
                # But since it's just named that, let's only do AppTheme.emerald/indigo to be safe.
                # In app_theme.dart, the constants themselves were renamed. Let's make sure app_theme.dart is also fixed.
                if 'app_theme.dart' in path:
                    new_content = re.sub(r'color: emerald', r'color: primaryCyan', new_content)
                    new_content = re.sub(r'color: indigo', r'color: secondaryBlue', new_content)

                if content != new_content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated colors in: {path}")

if __name__ == "__main__":
    replace_colors("lib")
