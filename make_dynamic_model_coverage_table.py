import getopt, sys
import csv


input_path = ""
output_path = ""
commit = ""


def process_command_line_options():
    global input_path
    global output_path
    global commit
    options = "i:o:c:"

    try:
        arguments, values = getopt.getopt(sys.argv[1:], options)

        for cur_arg, cur_val in arguments:
            if cur_arg in ("-i"):
                input_path = cur_val

            if cur_arg in ("-o"):
                output_path = cur_val

            if cur_arg in ("-c"):
                commit = cur_val

    except getopt.error as err:
        print(str(err))

    if input_path == "":
        print("input path is empty.")
        return False

    if output_path == "":
        print("output path is empty.")
        return False

    return True


def is_number(string):
    try:
        float(string)
        return True
    except ValueError:
        return False


def main():
    if process_command_line_options() == False:
        return

    models = {}

    with open(input_path, "r") as file:
        reader = csv.reader(file)
        for row in reader:
            reader = csv.reader(file)
            if row[0] not in models:
                models[row[0]] = {"GPU.0" : {"INT8" : "na", "FP16" : "na", "FP32" : "na"}, "GPU.1" : {"INT8" : "na", "FP16" : "na", "FP32" : "na"}}

            if row[3] == "no_model" or row[3] == "fail":
                models[row[0]][row[1]][row[2]] = row[3]
            elif is_number(row[3]):
                models[row[0]][row[1]][row[2]] = "OK"
                
    with open(output_path, "w") as file:
        writer = csv.writer(file)
        if commit != "":
            writer.writerow([commit])
        writer.writerow(["model", "GPU.0 INT8", "GPU.0 FP16", "GPU.0 FP32", "GPU.1 INT8", "GPU.1 FP16", "GPU.1 FP32"])

        for model_name, v in models.items():
            writer.writerow([model_name, v["GPU.0"]["INT8"], v["GPU.0"]["FP16"], v["GPU.0"]["FP32"], v["GPU.1"]["INT8"], v["GPU.1"]["FP16"], v["GPU.1"]["FP32"]])

    return


if __name__ == "__main__":
    main()

