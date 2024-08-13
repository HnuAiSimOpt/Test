import os
import numpy as np
import scipy.io as scio
import pywt
import matplotlib.pyplot as plt
import random
import shutil

# 常量定义
SEGMENT_SIZE = 512  # 数据分段的大小
MAX_SEGMENTS = 400  # 最大段数
WAVELET_NAME = 'cmor1-1'
SAMPLING_PERIOD_DEFAULT = 1.0 / 12000
TOTALSCALE_DEFAULT = 128
TRAIN_RATIO_DEFAULT = 0.7
OVERLAP_RATE_DEFAULT = 0.5


def ensure_directory_exists(directory):
    """确保目录存在，如果不存在则创建它。"""
    os.makedirs(directory, exist_ok=True)


"""
生成并保存单个频谱图
"""


def create_contour_image(data_segment, sampling_period, totalscal, wavename, save_path, base_name, segment_num):
    fc = pywt.central_frequency(wavename)  # 计算所选小波的中心频率
    cparam = 2 * fc * totalscal
    scales = cparam / np.arange(totalscal, 0, -1)
    coefficients, frequencies = pywt.cwt(data_segment, scales, wavename, sampling_period)
    amp = np.abs(coefficients)
    t = np.linspace(0, sampling_period * len(data_segment), len(data_segment), endpoint=False)

    plt.figure(figsize=(6, 3))
    plt.contourf(t, frequencies, amp, cmap='jet')
    plt.axis('off')
    plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
    plt.savefig(f"{save_path}{base_name}_{segment_num}.jpg")
    plt.close()


"""
处理单个文件，生成并保存图像。
- file_path 文件路径
- save_base_path 图像存储路径
- sampling_period=SAMPLING_PERIOD_DEFAULT  采样周期
- totalscal=TOTALSCALE_DEFAULT  总规模
- wavename=WAVELET_NAME  使用的小波变换名称
"""


def generate_images_per_file(file_path, save_base_path, sampling_period=SAMPLING_PERIOD_DEFAULT,
                             totalscal=TOTALSCALE_DEFAULT, wavename=WAVELET_NAME, overlap_rate=OVERLAP_RATE_DEFAULT):
    # 文件保存路径
    save_path = os.path.join(save_base_path, os.path.basename(file_path).split('.')[0]) + "/"
    # 确保路径存在
    ensure_directory_exists(save_path)
    # 加载.mat文件
    file_content = scio.loadmat(file_path)
    for key in file_content.keys():
        if 'DE' in key:

            overlap_samples = int(SEGMENT_SIZE * overlap_rate)
            # 调整每段的实际长度以考虑重叠
            effective_segment_size = SEGMENT_SIZE - overlap_samples
            data = file_content[key].reshape(-1)[:effective_segment_size * MAX_SEGMENTS]  # 确保数据足够
            # 开始和结束索引初始化
            start_idx = 0
            end_idx = effective_segment_size
            while end_idx <= len(data):
                # 处理当前数据段
                current_segment = data[start_idx:end_idx]
                create_contour_image(current_segment, sampling_period, totalscal, wavename,
                                     save_path, os.path.basename(file_path).split('.')[0],
                                     (start_idx // effective_segment_size) + 1)

                # 更新下一段的起始和结束索引
                start_idx += effective_segment_size
                end_idx = start_idx + effective_segment_size

                # 最后一段可能不需要再移动，避免越界
                if end_idx > len(data):
                    break


def split_and_organize_images(images_root, output_root):
    """分割并组织图像到训练集和测试集。"""
    ensure_directory_exists(output_root)
    train_dir = os.path.join(output_root, 'train')
    test_dir = os.path.join(output_root, 'test')
    ensure_directory_exists(train_dir)
    ensure_directory_exists(test_dir)

    for root, dirs, files in os.walk(images_root):
        for file in files:
            if file.endswith(('.jpg', '.png', '.jpeg')):
                source_path = os.path.join(root, file)
                target_dir = train_dir if random.random() < TRAIN_RATIO_DEFAULT else test_dir
                shutil.move(source_path, os.path.join(target_dir, file))


def prepare_dataset(input_dir, output_dir):
    """准备数据集，包括小波变换图像生成和数据集分割。"""
    ensure_directory_exists(output_dir)
    file_list = [os.path.join(root, name) for root, _, files in os.walk(input_dir) for name in files]
    for file_path in file_list:
        generate_images_per_file(file_path, output_dir)

    # 分割并整理数据集
    for subdir in os.listdir(output_dir):
        if subdir not in ['train', 'test']:
            sub_path = os.path.join(output_dir, subdir)
            split_and_organize_images(sub_path, output_dir)
            if not os.listdir(sub_path):  # 检查是否为空
                os.rmdir(sub_path)
    print('数据集准备及分割完成!')
    move_files_to_prefix_folders(os.path.join(output_dir, 'train'))
    print('训练集准备完毕!')
    print('测试集准备中。。。。')
    move_files_to_prefix_folders(os.path.join(output_dir, 'test'))
    print('测试集准备完毕!')
    set_up_val_set(output_dir, output_dir + r"\\val\\")


def move_files_to_prefix_folders(base_path):
    """
    根据文件名前缀将文件移动到对应的子目录中。

    :param base_path: 字符串，原始文件所在基准路径。
    """
    for filename in os.listdir(base_path):
        # 解析文件名前缀
        prefix = '_'.join(filename.split('_')[:-1])
        # 构建源文件和目标文件的完整路径
        src_file_path = os.path.join(base_path, filename)
        dest_folder_path = os.path.join(base_path, prefix)

        # 确保目标文件夹存在
        if os.path.isdir(dest_folder_path):
            dest_file_path = os.path.join(dest_folder_path, filename)
            # 移动文件到对应的前缀文件夹内
            try:
                shutil.move(src_file_path, dest_file_path)
                # print(f"文件'{filename}'移动到'{dest_folder_path}'成功。")
            except Exception as e:
                print(f"移动文件'{filename}'时出错: {e}")
        else:
            print(f"目标文件夹'{prefix}'不存在....")

            os.mkdir(dest_folder_path)
            # print(f"创建文件夹{prefix}成功")
            dest_file_path = os.path.join(dest_folder_path, filename)
            # 移动文件到对应的前缀文件夹内
            try:
                shutil.move(src_file_path, dest_file_path)
                # print(f"文件'{filename}'移动到'{dest_folder_path}'成功。")
            except Exception as e:
                print(f"移动文件'{filename}'时出错: {e}")


# 构造域适应验证集
def set_up_val_set(file_dir, output_dir):
    print("验证集准备中！！！")
    ensure_directory_exists(output_dir)
    filelist = [os.path.join(file_dir, item) for item in os.listdir(file_dir)]
    src_class_A_o = filelist[0]  # test
    src_class_B_o = filelist[1]  # train
    src_class_C_o = filelist[2]  # val
    for class_name in os.listdir(src_class_A_o):
        # 构建源目录和目标目录的完整路径
        src_class_A = os.path.join(src_class_A_o, class_name)
        src_class_B = os.path.join(src_class_B_o, class_name)
        tgt_class = os.path.join(src_class_C_o, class_name)

        # 在目标目录下创建对应的类别文件夹
        os.makedirs(tgt_class, exist_ok=True)

        # 从A复制文件
        for filename in os.listdir(src_class_A):
            src_file_A = os.path.join(src_class_A, filename)
            tgt_file_A = os.path.join(tgt_class, filename)
            shutil.copy2(src_file_A, tgt_file_A)  # 使用copy2保留元数据如修改时间等

        # 从B复制文件，注意检查是否已存在以避免覆盖
        for filename in os.listdir(src_class_B):
            src_file_B = os.path.join(src_class_B, filename)
            tgt_file_B = os.path.join(tgt_class, filename)
            # 如果文件已经存在，可以选择跳过、覆盖或其他逻辑
            if not os.path.exists(tgt_file_B):
                shutil.copy2(src_file_B, tgt_file_B)

    print("验证集准备完成！！")


if __name__ == "__main__":
    # base = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\\"
    # inputpath_list = ["1797_12K_load0", "1772_12K_load1", "1750_12K_load2", "1730_12K_load3"]
    # for path in inputpath_list:
    #     input_path = base + path + r"\\"
    #     output_path = base + path + r"_final\\"
    #     # print(input_path)
    #     # print(output_path)
    #     print(f"准备数据集{path}中。。。。。")
    #     prepare_dataset(input_path, output_path)
    # input_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1797_12K_load0"
    # output_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1797_12K_load0_final\\"
    # prepare_dataset(input_dir, output_dir)
    input_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1772_12K_load1"
    output_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1772_12K_load1_final\\"
    prepare_dataset(input_dir, output_dir)
    input_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1750_12K_load2"
    output_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1750_12K_load2_final\\"
    prepare_dataset(input_dir, output_dir)
    input_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1730_12K_load3"
    output_dir = r"G:\数据集\机械故障诊断数据集\CRWU_4domain\1730_12K_load3_final\\"
    prepare_dataset(input_dir, output_dir)
