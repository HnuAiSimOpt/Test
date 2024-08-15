import matplotlib.pyplot as plt
import xlwt
from scipy.signal import savgol_filter

def smooth(rotation_list):
    # 进行滤波处理
    if len(rotation_list) > 10:  # 至少有10个值才进行滤波
        smoothed_roll_angles = savgol_filter(rotation_list, 9, 3)  # Savitzky-Golay滤波器
    else:
        smoothed_roll_angles = rotation_list
    return smoothed_roll_angles

def plot_data(time_list, rotation_x_list, rotation_y_list, rotation_z_list, acceleration_x_list, acceleration_y_list):
    plt.figure(figsize=(10, 8))

    # 绘制 Rotation X 和 Rotation Z 曲线
    plt.subplot(2, 1, 1)
    plt.plot(time_list, rotation_x_list, 'r-', label='Rotation X')
    plt.plot(time_list, rotation_y_list, 'b-', label='Rotation Y')
    plt.plot(time_list, rotation_z_list, 'g-', label='Rotation Z')
    plt.xlabel('Time (s)')
    plt.ylabel('Rotation (degrees)')
    plt.title('Rotation vs Time')
    plt.legend(loc='upper left')
    plt.grid(True)

    # 绘制 Acceleration X 和 Acceleration Y 曲线
    plt.subplot(2, 1, 2)
    plt.plot(time_list, acceleration_x_list, 'b-', label='Acceleration X')
    plt.plot(time_list, acceleration_y_list, 'g-', label='Acceleration Y')
    plt.xlabel('Time (s)')
    plt.ylabel('Acceleration')
    plt.title('Acceleration vs Time')
    plt.legend(loc='upper left')
    plt.grid(True)

    plt.tight_layout()
    plt.show()

def save_to_excel(time_list, rotation_x_list,rotation_y_list, rotation_z_list, acceleration_x_list, acceleration_y_list):
    workbook = xlwt.Workbook()
    worksheet = workbook.add_sheet('Data')
    worksheet.write(0, 0, 'Time (s)')
    worksheet.write(0, 1, 'Rotation X')
    worksheet.write(0, 2, 'Rotation Y')
    worksheet.write(0, 3, 'Rotation Z')
    worksheet.write(0, 4, 'Acceleration X')
    worksheet.write(0, 5, 'Acceleration Y')
    for i in range(len(time_list)):
        worksheet.write(i + 1, 0, time_list[i])
        worksheet.write(i + 1, 1, rotation_x_list[i])
        worksheet.write(i + 1, 2, rotation_y_list[i])
        worksheet.write(i + 1, 3, rotation_z_list[i])
        worksheet.write(i + 1, 4, acceleration_x_list[i])
        worksheet.write(i + 1, 5, acceleration_y_list[i])
    workbook.save('result.xls')