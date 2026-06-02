import os
import re

logs_dir = r'C:\Users\ANKAN\.gemini\antigravity\brain'
target_dir = r'C:\Users\ANKAN\Desktop\My Projects\Flutter\Pdf Doc scanner app\lib'

log_files = []
for root, _, files in os.walk(logs_dir):
    if 'overview.txt' in files:
        path = os.path.join(root, 'overview.txt')
        log_files.append((os.path.getctime(path), path))
log_files.sort()

file_contents = {}

for _, log_file in log_files:
    try:
        with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            # Find write_to_file calls
            # The format is usually JSON inside the log or a specific block
            # Since overview.txt is a raw transcript of the conversation, it has
            # "TargetFile": "...", "CodeContent": "..."
            
            # Simple regex to find TargetFile and CodeContent
            # Sometimes it's printed as "The following changes were made by the write_to_file tool to: <path>. ... [diff_block_start] ... [diff_block_end]" Wait no, write_to_file doesn't output diff blocks!
            
            # Let's search for the raw tool call JSON.
            # "name": "default_api:write_to_file", "parameters": { ... }
            matches = re.finditer(r'"name"\s*:\s*"default_api:write_to_file".*?"parameters"\s*:\s*({.+?})\s*}', content, re.DOTALL)
            for m in matches:
                import json
                try:
                    params_str = m.group(1)
                    # This might be tricky if JSON is nested or escaped.
                    # Let's try to parse
                    # Add } to complete the parameters object
                    params = json.loads(params_str + "}") 
                    path = params.get("TargetFile", "")
                    code = params.get("CodeContent", "")
                    if "Pdf Doc scanner app" in path and "lib" in path:
                        norm_path = os.path.normpath(path)
                        file_contents[norm_path] = code
                except Exception as ex:
                    pass
    except Exception as e:
        pass

recovered = 0
for path, code in file_contents.items():
    if os.path.exists(path):
        with open(path, 'w', encoding='utf-8') as f:
            f.write(code)
        print(f"Recovered: {path}")
        recovered += 1

print(f"Total recovered: {recovered}")
