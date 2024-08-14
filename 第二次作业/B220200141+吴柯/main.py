import cv2
import numpy as np
import matplotlib.pyplot as plt
from SavePlot import plot_data,save_to_excel,smooth
from RoAccXY import calculate_rotation, calculate_acceleration,calculate_y


# 启用OpenCL加速
cv2.ocl.setUseOpenCL(True)

# 参数配置
VIDEO_PATH = 'D:/WKproject/WK/Tmo/Motion Sickness/VRMS/test1.mp4'
UNIT_LENGTH = 200
WINDOW_LENGTH = 10

def main():
    cap = cv2.VideoCapture(VIDEO_PATH)

    if not cap.isOpened():
        print("Error: Unable to open video file.")
        exit()

    rotation_x_list = []
    rotation_y_list = []
    rotation_z_list = []
    displacement_x_list = []
    displacement_y_list = []
    acceleration_x_list = []
    acceleration_y_list = []
    time_list = []
    # 初始化初始值为零的变量
    initial_rotation_x = 0
    initial_rotation_y = 0
    initial_rotation_z = 0
    initial_acceleration_x = 0
    initial_acceleration_y = 0

    plt.ion()
    fig, (ax1, ax2) = plt.subplots(2, 1)
    fig.subplots_adjust(hspace=0.5)
    line1, = ax1.plot([], [], 'r-', label='Rotation X')
    line2, = ax1.plot([], [], 'b-', label='Rotation Y')
    line3, = ax1.plot([], [], 'g-', label='Rotation Z')
    line4, = ax2.plot([], [], 'b-', label='Acceleration X')
    line5, = ax2.plot([], [], 'g-', label='Acceleration Y')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Rotation (degrees)')
    ax1.set_title('Rotation vs Time')
    ax1.legend(loc='upper left')
    ax1.grid(True)
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Acceleration')
    ax2.set_title('Acceleration vs Time')
    ax2.legend(loc='upper left')
    ax2.grid(True)

    plt.show()

    frame_count = 0
    # 读取第一帧
    ret, prev_frame = cap.read()
    while True:
        # 读取下一帧
        ret, next_frame = cap.read()
        # 如果没有下一帧，退出循环
        if not ret:
            break

        gray1 = cv2.cvtColor(prev_frame, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(next_frame, cv2.COLOR_BGR2GRAY)

        if next_frame is not None:
            dt = 1.0 / cap.get(cv2.CAP_PROP_FPS)

            rotation_x, rotation_z, flow = calculate_rotation(gray2, gray1, UNIT_LENGTH)
            rotation_y = calculate_y(gray1,gray2)

            # 确定初始值
            if frame_count == 0:
                initial_rotation_x = rotation_x
                initial_rotation_y = rotation_y
                initial_rotation_z = rotation_z

            # 计算角度时减去初始值
            rotation_x -= initial_rotation_x
            rotation_y -= initial_rotation_y
            rotation_z -= initial_rotation_z
            rotation_x_list.append(rotation_x)
            rotation_y_list.append(rotation_y)
            rotation_z_list.append(rotation_z)
            smooth_rotation_x_list = smooth(rotation_x_list)
            smooth_rotation_y_list = smooth(rotation_y_list)
            smooth_rotation_z_list = smooth(rotation_z_list)

            dx = np.mean(flow[..., 0])
            dy = np.mean(flow[..., 1])
            displacement_x_list.append(dx)
            displacement_y_list.append(dy)

            acceleration_x = calculate_acceleration(displacement_x_list, dt, WINDOW_LENGTH)
            acceleration_y = calculate_acceleration(displacement_y_list, dt, WINDOW_LENGTH)

            # 确定初始值
            if frame_count == 0:
                initial_acceleration_x = acceleration_x
                initial_acceleration_y = acceleration_y

            # 计算加速度时减去初始值
            acceleration_x -= initial_acceleration_x
            acceleration_y -= initial_acceleration_y
            acceleration_x_list.append(acceleration_x)
            acceleration_y_list.append(acceleration_y)

            time_seconds = frame_count / cap.get(cv2.CAP_PROP_FPS)
            time_list.append(time_seconds)

            line1.set_xdata(time_list)
            line1.set_ydata(smooth_rotation_x_list)
            line2.set_xdata(time_list)
            line2.set_ydata(smooth_rotation_y_list)
            line3.set_xdata(time_list)
            line3.set_ydata(smooth_rotation_z_list)
            line4.set_xdata(time_list)
            line4.set_ydata(acceleration_x_list)
            line5.set_xdata(time_list)
            line5.set_ydata(acceleration_y_list)
            ax1.relim()
            ax1.autoscale_view(True, True, True)
            ax2.relim()
            ax2.autoscale_view(True, True, True)
            fig.canvas.draw()
            fig.canvas.flush_events()

            frame_count += 1

        cv2.imshow('Optical Flow', next_frame)
        # 更新前一帧
        prev_frame = next_frame

        if cv2.waitKey(30) & 0xFF == ord('q'):
            break

    cap.release()
    plot_data(time_list, smooth_rotation_x_list,smooth_rotation_y_list, smooth_rotation_z_list, acceleration_x_list, acceleration_y_list)
    save_to_excel(time_list, smooth_rotation_x_list, smooth_rotation_x_list,rotation_z_list, acceleration_x_list, acceleration_y_list)

    # 等待用户手动关闭窗口
    plt.ioff()
    plt.show()

if __name__ == "__main__":
    main()