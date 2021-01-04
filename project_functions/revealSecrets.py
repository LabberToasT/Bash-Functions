import base64, sys

def revealSecrets(input_file):
    if not project_supports_secets():
        print("Project has no secrets. Aborting!")
        return

    secrets_file = open(input_file, "r")

    new_file_content = ""
    should_skip = False
    for line in secrets_file:
        if line == 'data:\n':
            new_file_content += line
            should_skip = True
            continue

        if should_skip is False:
            new_file_content += line
            continue

        new_file_content += "".join(decode_secrets_line(line))

    open(input_file, "w").write(new_file_content)

def decode_string(encoded_value):
    decoded_value = base64.b64decode(encoded_value)

    return decoded_value.decode('utf-8')

def format_line(unformatted_line):
    unformatted_line.insert(0, "  ")
    unformatted_line.insert(2, " ")
    unformatted_line.append("\n")

    return unformatted_line

def decode_secrets_line(encoded_line):
    broken_line = encoded_line.split()
    broken_line[1] = decode_string(broken_line[1])

    return format_line(broken_line)

def project_supports_secets():
    return True

if __name__ == "__main__":
    revealSecrets(sys.argv[1])
