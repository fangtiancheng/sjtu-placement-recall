import pandas as pd
import matplotlib.pyplot as plt
from typing import List, Tuple
from matplotlib import font_manager
import numpy as np


font_path = 'C:\\Windows\\Fonts\\msyh.ttc'  # 微软雅黑字体路径，Windows系统
font_prop = font_manager.FontProperties(fname=font_path)

data = pd.read_excel('result.xlsx')
score_rank:List[Tuple[int, int]] = []

for score, rank in zip(data['Q2. 您的能力测试得分为'], data['Q3. 您的能力测试排名（整数）为']):
    try: 
        score, rank = int(score), int(rank)
        if rank == 0 or score == 0:
            continue
    except ValueError:
        print('ValueError:', score, rank)
        continue
    score_rank.append((score, rank))
scores, ranks = zip(*sorted(score_rank, key=lambda x: x[0]))

scores = np.array(scores)
ranks = np.array(ranks)

def split_normals_outliers(x: np.ndarray, y: np.ndarray, xmin: float, xmax: float) ->\
    Tuple[Tuple[np.ndarray, np.ndarray], Tuple[np.ndarray, np.ndarray]]:
    """
    将数据点分为正常点和离群点，其中离群点为 xmin 到 xmax 范围内远离最小二乘法拟合直线的点。

    参数：
    x (np.ndarray): x 轴数据（例如，得分）。
    y (np.ndarray): y 轴数据（例如，排名）。
    xmin (float): x 轴的最小阈值。
    xmax (float): x 轴的最大阈值。

    返回：
    Tuple[Tuple[np.ndarray, np.ndarray], Tuple[np.ndarray, np.ndarray]]:
        - 第一个元组包含正常点的 (x, y) 数组。
        - 第二个元组包含离群点的 (x, y) 数组。
    """
    # 使用最小二乘法拟合直线
    in_idx = np.where(np.logical_and(xmin <= x, x < xmax))[0]
    out_idx = np.where(np.logical_or(xmin > x, x >= xmax))[0]
    x_in, y_in = x[in_idx], y[in_idx]
    A = np.vstack([x_in, np.ones(len(x_in))]).T
    slope, intercept = np.linalg.lstsq(A, y_in, rcond=None)[0]

    # 计算拟合直线上的对应 y 值
    fitted_y = slope * x_in + intercept

    # 计算每个点到拟合直线的垂直距离
    distances = np.abs(y_in - fitted_y)

    # 设定一个距离阈值，使用距离的平均值加上 2 倍标准差作为阈值
    threshold = np.mean(distances) + 2 * np.std(distances)

    # 分离正常点和离群点
    outlier_idx = in_idx[np.where(distances > threshold)[0]]
    normal_idx = np.concatenate([out_idx, in_idx[np.where(distances <= threshold)[0]]])
    # 提取正常点和离群点的 x 和 y 值
    normal_x = x[normal_idx]
    normal_y = y[normal_idx]
    outlier_x = x[outlier_idx]
    outlier_y = y[outlier_idx]

    # 返回 (正常点的 (x, y), 离群点的 (x, y))
    return (normal_x, normal_y), (outlier_x, outlier_y)

(normal_x, normal_y), (outlier_x, outlier_y) = split_normals_outliers(scores, ranks, 70, 86)

plt.figure(figsize=(8, 8))
# plt.scatter(scores, ranks, marker='x')
normal_plot = plt.scatter(normal_x, normal_y, marker='x', color='blue', alpha=0.6)
outlier_plot = plt.scatter(outlier_x, outlier_y, marker='x', color='red', alpha=0.6)
plt.legend((normal_plot, outlier_plot), ('正常点', '离群点'), loc='best', prop=font_prop)
print(outlier_x, outlier_y)

plt.title('能力测试得分与能力测试排名散点图', fontproperties=font_prop)
plt.xlabel('能力测试得分', fontproperties=font_prop)
plt.ylabel('能力测试排名', fontproperties=font_prop)
plt.grid()
plt.tight_layout()
# plt.show()
plt.savefig('能力测试得分与能力测试排名散点图.png', dpi=600)
