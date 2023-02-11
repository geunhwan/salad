import getopt, sys
import pandas as pd
import functools as ft
from scipy.stats.mstats import gmean


idirectory = "./"
odirectory = "./"
oprefix = ""
ww_list = []
ww_df = {}


def process_commandline_options():
    options = "hd:i:o:"
    long_options = ["help", "input_list=", "output_prefix="]
    input_list = "ilist"
    global idirectory, odirectory
    global oprefix
    global ww_list

    try:
        arguments, values = getopt.getopt(sys.argv[1 : ], options, long_options)

        for cur_arg, cur_val in arguments:
            if cur_arg in ("-h", "--help"):
                print("Pandas needs to be installed.")
                print("Run venv: source ~/work/pyenv/personal/bin/activate")
                print(sys.argv[0] + " -d [directory] -i [input list file (optional)] -o [output prefix]")
                print("example: " + sys.argv[0] + " -d dg2_perf_report -o ww06.1_")
                return False
            elif cur_arg in ("-d"):
                idirectory = cur_val + "/input/"
                odirectory = cur_val + "/output/"
            elif cur_arg in ("-i", "--input_list"):
                input_list = cur_val
            elif cur_arg in ("-o", "--output_prefix"):
                oprefix = cur_val
    except getopt.error as err:
        print(str(err))
        return False
    
    ilistfile = open(idirectory + input_list, "r")
    ww_list = ilistfile.readlines();
    ww_list = list(map(lambda x : x[:-1], ww_list))
    ilistfile.close()

    return True


def process_ww_list():
    for ww in ww_list:
        ww_data = pd.read_csv(idirectory + ww, sep = "|")
        ww_data = ww_data.drop(ww_data.columns[[0, -1]], axis = 1).rename(columns = lambda x : x.strip()).drop(columns = ["msg", "b1/ref", "b32/ref", "b1/cldnn", "b32/cldnn", "b1fps_ref", "b32fps_ref"], axis = 1).drop(labels = 0, axis = 0)
        for column in ww_data.columns:
            ww_data[column] = ww_data[column].str.strip()
        ww_data = ww_data.set_index("name")
        ww_data["b1fps"]        = ww_data["b1fps"].astype(float)
        ww_data["b1fps_cldnn"]  = ww_data["b1fps_cldnn"].astype(float)
        ww_data["b32fps"]       = ww_data["b32fps"].astype(float)
        ww_data["b32fps_cldnn"] = ww_data["b32fps_cldnn"].astype(float)

        grouped = ww_data.groupby(ww_data["prec"])
        ww_int8 = grouped.get_group("int8").drop(columns = ["prec"])
        ww_fp16 = grouped.get_group("fp16").drop(columns = ["prec"])
        ww_fp32 = grouped.get_group("fp32").drop(columns = ["prec"])

        # Process B16 data in the seprate file
        ww_data = pd.read_csv(idirectory + ww + "_B16", sep = "|")
        ww_data = ww_data.drop(ww_data.columns[[0, -1]], axis = 1).rename(columns = lambda x : x.strip()).drop(columns = ["msg", "b16/ref", "b16/cldnn", "b16fps_ref"], axis = 1).drop(labels = 0, axis = 0)
        for column in ww_data.columns:
            ww_data[column] = ww_data[column].str.strip()
        ww_data = ww_data.set_index("name")
        ww_data["b16fps"]       = ww_data["b16fps"].astype(float)
        ww_data["b16fps_cldnn"] = ww_data["b16fps_cldnn"].astype(float)

        grouped = ww_data.groupby(ww_data["prec"])
        ww_int8 = ww_int8.join(grouped.get_group("int8").drop(columns = ["prec"]), how = "outer")
        ww_fp16 = ww_fp16.join(grouped.get_group("fp16").drop(columns = ["prec"]), how = "outer")
        ww_fp32 = ww_fp32.join(grouped.get_group("fp32").drop(columns = ["prec"]), how = "outer")

        ww_df[ww] = ww_int8.join(ww_fp16, how = "outer", lsuffix = "_int8", rsuffix = "_fp16").join(ww_fp32.rename(columns = lambda x : str(x) + "_fp32"), how = "outer")
        ww_df[ww] = ww_df[ww].loc[:, ["b1fps_int8", "b1fps_fp16", "b1fps_fp32", "b16fps_int8", "b16fps_fp16", "b16fps_fp32", "b32fps_int8", "b32fps_fp16", "b32fps_fp32", "b1fps_cldnn_int8", "b1fps_cldnn_fp16", "b1fps_cldnn_fp32", "b16fps_cldnn_int8", "b16fps_cldnn_fp16", "b16fps_cldnn_fp32", "b32fps_cldnn_int8", "b32fps_cldnn_fp16", "b32fps_cldnn_fp32"]]


def generate_joined_table():
    final_joined = pd.DataFrame()
    first = True

    for ww in ww_list:
        if first is True:
            final_joined = ww_df[ww].rename(columns = lambda x : x + "_" + ww)
            first = False
        else:
            final_joined = final_joined.join(ww_df[ww].rename(columns = lambda x : x + "_" + ww), how = "outer")
    
    final_joined.to_csv(odirectory + oprefix + "joined.csv")


def generate_vs_cldnn():
    vs_cldnn = pd.DataFrame(columns = ["vs_clDNN", "int8_b1", "int8_b16", "int8_b32", "fp16_b1", "fp16_b16", "fp16_b32", "fp32_b1", "fp32_b16", "fp32_b32"]).set_index("vs_clDNN")

    for ww in ww_list:
        int8_b1 = ww_df[ww][(ww_df[ww]["b1fps_int8"] > 0) & (ww_df[ww]["b1fps_cldnn_int8"] > 0)].loc[:, ["b1fps_int8", "b1fps_cldnn_int8"]]
        int8_b16 = ww_df[ww][(ww_df[ww]["b16fps_int8"] > 0) & (ww_df[ww]["b16fps_cldnn_int8"] > 0)].loc[:, ["b16fps_int8", "b16fps_cldnn_int8"]]
        int8_b32 = ww_df[ww][(ww_df[ww]["b32fps_int8"] > 0) & (ww_df[ww]["b32fps_cldnn_int8"] > 0)].loc[:, ["b32fps_int8", "b32fps_cldnn_int8"]]
        
        fp16_b1 = ww_df[ww][(ww_df[ww]["b1fps_fp16"] > 0) & (ww_df[ww]["b1fps_cldnn_fp16"] > 0)].loc[:, ["b1fps_fp16", "b1fps_cldnn_fp16"]]
        fp16_b16 = ww_df[ww][(ww_df[ww]["b16fps_fp16"] > 0) & (ww_df[ww]["b16fps_cldnn_fp16"] > 0)].loc[:, ["b16fps_fp16", "b16fps_cldnn_fp16"]]
        fp16_b32 = ww_df[ww][(ww_df[ww]["b32fps_fp16"] > 0) & (ww_df[ww]["b32fps_cldnn_fp16"] > 0)].loc[:, ["b32fps_fp16", "b32fps_cldnn_fp16"]]
        
        fp32_b1 = ww_df[ww][(ww_df[ww]["b1fps_fp32"] > 0) & (ww_df[ww]["b1fps_cldnn_fp32"] > 0)].loc[:, ["b1fps_fp32", "b1fps_cldnn_fp32"]]
        fp32_b16 = ww_df[ww][(ww_df[ww]["b16fps_fp32"] > 0) & (ww_df[ww]["b16fps_cldnn_fp32"] > 0)].loc[:, ["b16fps_fp32", "b16fps_cldnn_fp32"]]
        fp32_b32 = ww_df[ww][(ww_df[ww]["b32fps_fp32"] > 0) & (ww_df[ww]["b32fps_cldnn_fp32"] > 0)].loc[:, ["b32fps_fp32", "b32fps_cldnn_fp32"]]
        
        vs_cldnn.loc[ww] = [gmean(int8_b1.loc[:, "b1fps_int8"]) / gmean(int8_b1.loc[:, "b1fps_cldnn_int8"]), gmean(int8_b16.loc[:, "b16fps_int8"]) / gmean(int8_b16.loc[:, "b16fps_cldnn_int8"]), gmean(int8_b32.loc[:, "b32fps_int8"]) / gmean(int8_b32.loc[:, "b32fps_cldnn_int8"]),
                            gmean(fp16_b1.loc[:, "b1fps_fp16"]) / gmean(fp16_b1.loc[:, "b1fps_cldnn_fp16"]), gmean(fp16_b16.loc[:, "b16fps_fp16"]) / gmean(fp16_b16.loc[:, "b16fps_cldnn_fp16"]), gmean(fp16_b32.loc[:, "b32fps_fp16"]) / gmean(fp16_b32.loc[:, "b32fps_cldnn_fp16"]),
                            gmean(fp32_b1.loc[:, "b1fps_fp32"]) / gmean(fp32_b1.loc[:, "b1fps_cldnn_fp32"]), gmean(fp32_b16.loc[:, "b16fps_fp32"]) / gmean(fp32_b16.loc[:, "b16fps_cldnn_fp32"]), gmean(fp32_b32.loc[:, "b32fps_fp32"]) / gmean(fp32_b32.loc[:, "b32fps_cldnn_fp32"])]

    vs_cldnn.to_csv(odirectory + oprefix + "vs_cldnn.csv")


def generate_prec_scale():
    prec_scale = pd.DataFrame(columns = ["prec_scale", "int8_fp16_b1", "int8_fp16_b16", "int8_fp16_b32", "fp16_fp32_b1", "fp16_fp32_b16", "fp16_fp32_b32"]).set_index("prec_scale")

    for ww in ww_list:
        int8_fp16_b1 = ww_df[ww][(ww_df[ww]["b1fps_int8"] > 0) & (ww_df[ww]["b1fps_fp16"] > 0)].loc[:, ["b1fps_int8", "b1fps_fp16"]]
        int8_fp16_b16 = ww_df[ww][(ww_df[ww]["b16fps_int8"] > 0) & (ww_df[ww]["b16fps_fp16"] > 0)].loc[:, ["b16fps_int8", "b16fps_fp16"]]
        int8_fp16_b32 = ww_df[ww][(ww_df[ww]["b32fps_int8"] > 0) & (ww_df[ww]["b32fps_fp16"] > 0)].loc[:, ["b32fps_int8", "b32fps_fp16"]]

        fp16_fp32_b1 = ww_df[ww][(ww_df[ww]["b1fps_fp32"] > 0) & (ww_df[ww]["b1fps_fp16"] > 0)].loc[:, ["b1fps_fp32", "b1fps_fp16"]]
        fp16_fp32_b16 = ww_df[ww][(ww_df[ww]["b16fps_fp32"] > 0) & (ww_df[ww]["b16fps_fp16"] > 0)].loc[:, ["b16fps_fp32", "b16fps_fp16"]]
        fp16_fp32_b32 = ww_df[ww][(ww_df[ww]["b32fps_fp32"] > 0) & (ww_df[ww]["b32fps_fp16"] > 0)].loc[:, ["b32fps_fp32", "b32fps_fp16"]]
        
        prec_scale.loc[ww] = [gmean(int8_fp16_b1.loc[:, "b1fps_int8"]) / gmean(int8_fp16_b1.loc[:, "b1fps_fp16"]), gmean(int8_fp16_b16.loc[:, "b16fps_int8"]) / gmean(int8_fp16_b16.loc[:, "b16fps_fp16"]), gmean(int8_fp16_b32.loc[:, "b32fps_int8"]) / gmean(int8_fp16_b32.loc[:, "b32fps_fp16"]),
                              gmean(fp16_fp32_b1.loc[:, "b1fps_fp16"]) / gmean(fp16_fp32_b1.loc[:, "b1fps_fp32"]), gmean(fp16_fp32_b16.loc[:, "b16fps_fp16"]) / gmean(fp16_fp32_b16.loc[:, "b16fps_fp32"]), gmean(fp16_fp32_b32.loc[:, "b32fps_fp16"]) / gmean(fp16_fp32_b32.loc[:, "b32fps_fp32"])]

    prec_scale.to_csv(odirectory + oprefix + "prec_scale.csv")


def generate_perf_trend():
    perf_trend = pd.DataFrame(columns = ["perf_trend", "int8_b1", "int8_b16", "int8_b32", "fp16_b1", "fp16_b16", "fp16_b32", "fp32_b1", "fp32_b16", "fp32_b32"]).set_index("perf_trend")
    joined = {}
    first = True

    for ww in ww_list:
        if first is True:
            joined["int8_b1"] = ww_df[ww][ww_df[ww]["b1fps_int8"] > 0].loc[:, ["b1fps_int8"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp16_b1"] = ww_df[ww][ww_df[ww]["b1fps_fp16"] > 0].loc[:, ["b1fps_fp16"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp32_b1"] = ww_df[ww][ww_df[ww]["b1fps_fp32"] > 0].loc[:, ["b1fps_fp32"]].rename(columns = lambda x : x + "_" + ww)
            joined["int8_b16"] = ww_df[ww][ww_df[ww]["b16fps_int8"] > 0].loc[:, ["b16fps_int8"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp16_b16"] = ww_df[ww][ww_df[ww]["b16fps_fp16"] > 0].loc[:, ["b16fps_fp16"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp32_b16"] = ww_df[ww][ww_df[ww]["b16fps_fp32"] > 0].loc[:, ["b16fps_fp32"]].rename(columns = lambda x : x + "_" + ww)
            joined["int8_b32"] = ww_df[ww][ww_df[ww]["b32fps_int8"] > 0].loc[:, ["b32fps_int8"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp16_b32"] = ww_df[ww][ww_df[ww]["b32fps_fp16"] > 0].loc[:, ["b32fps_fp16"]].rename(columns = lambda x : x + "_" + ww)
            joined["fp32_b32"] = ww_df[ww][ww_df[ww]["b32fps_fp32"] > 0].loc[:, ["b32fps_fp32"]].rename(columns = lambda x : x + "_" + ww)
            first = False
        else:
            joined["int8_b1"] = joined["int8_b1"].join(ww_df[ww][ww_df[ww]["b1fps_int8"] > 0].loc[:, ["b1fps_int8"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp16_b1"] = joined["fp16_b1"].join(ww_df[ww][ww_df[ww]["b1fps_fp16"] > 0].loc[:, ["b1fps_fp16"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp32_b1"] = joined["fp32_b1"].join(ww_df[ww][ww_df[ww]["b1fps_fp32"] > 0].loc[:, ["b1fps_fp32"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["int8_b16"] = joined["int8_b16"].join(ww_df[ww][ww_df[ww]["b16fps_int8"] > 0].loc[:, ["b16fps_int8"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp16_b16"] = joined["fp16_b16"].join(ww_df[ww][ww_df[ww]["b16fps_fp16"] > 0].loc[:, ["b16fps_fp16"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp32_b16"] = joined["fp32_b16"].join(ww_df[ww][ww_df[ww]["b16fps_fp32"] > 0].loc[:, ["b16fps_fp32"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["int8_b32"] = joined["int8_b32"].join(ww_df[ww][ww_df[ww]["b32fps_int8"] > 0].loc[:, ["b32fps_int8"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp16_b32"] = joined["fp16_b32"].join(ww_df[ww][ww_df[ww]["b32fps_fp16"] > 0].loc[:, ["b32fps_fp16"]].rename(columns = lambda x : x + "_" + ww), how = "inner")
            joined["fp32_b32"] = joined["fp32_b32"].join(ww_df[ww][ww_df[ww]["b32fps_fp32"] > 0].loc[:, ["b32fps_fp32"]].rename(columns = lambda x : x + "_" + ww), how = "inner")

    for ww in ww_list:
        perf_trend.loc[ww] = [gmean(joined["int8_b1"].loc[:, "b1fps_int8_" + ww]), gmean(joined["int8_b16"].loc[:, "b16fps_int8_" + ww]), gmean(joined["int8_b32"].loc[:, "b32fps_int8_" + ww]),
                              gmean(joined["fp16_b1"].loc[:, "b1fps_fp16_" + ww]), gmean(joined["fp16_b16"].loc[:, "b16fps_fp16_" + ww]), gmean(joined["fp16_b32"].loc[:, "b32fps_fp16_" + ww]),
                              gmean(joined["fp32_b1"].loc[:, "b1fps_fp32_" + ww]), gmean(joined["fp32_b16"].loc[:, "b16fps_fp32_" + ww]), gmean(joined["fp32_b32"].loc[:, "b32fps_fp32_" + ww])]

    first_row = perf_trend.iloc[0].copy()
    for ww in ww_list:
        perf_trend.loc[ww] /= first_row

    perf_trend.to_csv(odirectory + oprefix + "perf_trend.csv")


def main():
    if process_commandline_options() == False:
        return

    process_ww_list()

    generate_joined_table()
    generate_vs_cldnn()
    generate_prec_scale()
    generate_perf_trend()


if __name__ == "__main__":
    main()
