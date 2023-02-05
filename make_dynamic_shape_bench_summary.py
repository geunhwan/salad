import getopt, sys
import csv


report_path = ""


def process_command_line_options():
    global report_path
    options = "p:"

    try:
        arguments, values = getopt.getopt(sys.argv[1:], options)

        for cur_arg, cur_val in arguments:
            if cur_arg in ("-p"):
                report_path = cur_val + "/"
    except getopt.error as err:
        print(str(err))

    if report_path == "":
        print("report path is empty.")
        return False

    return True


def get_throughput(file_path):
    with open(file_path, "r") as file:
        reader = csv.reader(file, delimiter=";")
        for row in reader:
            if len(row) > 1 and row[0] == "throughput":
                return row[1]

    return "-1"


def summarize_model(report_path, model_name):
    model_summary = [model_name]

    model_summary.append(get_throughput(report_path + model_name + "_static.csv"))
    model_summary.append(get_throughput(report_path + model_name + "_dynamic.csv"))
    for i in range(10):
        model_summary.append(get_throughput(report_path + model_name + "_dynamic_" + str(i) + ".csv"))

    return model_summary


def main():
    if process_command_line_options() == False:
        return

    with open(report_path + "summary.csv", "w") as file:
        writer = csv.writer(file)
        writer.writerow(["model name", "static", "dynamic", "dynamic_0", "dynamic_1", "dynamic_2", "dynamic_3", "dynamic_4", "dynamic_5", "dynamic_6", "dynamic_7", "dynamic_8", "dynamic_9"])
        writer.writerow(summarize_model(report_path, "bert_small"))
        writer.writerow(summarize_model(report_path, "bert_base"))
        writer.writerow(summarize_model(report_path, "bert_large"))

    return


if __name__ == "__main__":
    main()

