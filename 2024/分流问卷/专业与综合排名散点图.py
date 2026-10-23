import pandas as pd
import matplotlib.pyplot as plt
from typing import List, Dict, Tuple
from matplotlib import font_manager

font_path = 'C:\\Windows\\Fonts\\msyh.ttc'  # 微软雅黑字体路径，Windows系统
font_prop = font_manager.FontProperties(fname=font_path)

data = pd.read_excel('result.xlsx')
accept:Dict[str, List[int]] = {}
reject:Dict[str, List[int]] = {}

for rank, major in zip(data['Q5. 您的综合排名（整数）为'], data['Q6. 您的录取专业为']):
    if major not in accept.keys():
        accept[major] = []
        reject[major] = []
    rank = int(rank)
    accept[major].append(rank)

major_list:List[Tuple[str, int]] = []
for major, ranks in accept.items():
    last_rank = max(ranks)
    major_list.append((major, last_rank))
major_list = sorted(major_list, key=lambda x: x[1])

major_to_rank:Dict[str, int] = {}
y_ticks, y_labels = [], []
for major_rank, (major, _) in enumerate(major_list):
    major_to_rank[major] = major_rank
    y_ticks.append(major_rank)
    y_labels.append(major)
print(major_to_rank)
for rank, majors in zip(data['Q5. 您的综合排名（整数）为'], data['Q7. 您是否有未被录取的专业']):
    majors:str = majors.strip()
    rank = int(rank)
    if majors == '我是第一志愿录取的':
        continue
    for major in majors.split('、'):
        reject[major.strip()].append(rank)
    
# 绘图
plt.figure(figsize=(16, 4))

for major, major_rank in major_to_rank.items():
    accept_plot = plt.scatter(accept[major], [major_rank] * len(accept[major]), color='blue', alpha=0.6, marker='x')
    reject_plot = plt.scatter(reject[major], [major_rank] * len(reject[major]), color='red', alpha=0.6, marker='x')


# 设置纵坐标的标签和顺序
plt.xticks(range(0, max(data['Q5. 您的综合排名（整数）为']), 20))
plt.yticks(y_ticks, y_labels, fontproperties=font_prop)
plt.title('专业与综合排名散点图', fontproperties=font_prop)
plt.xlabel('综合排名', fontproperties=font_prop)
plt.ylabel('专业', fontproperties=font_prop)
plt.legend((accept_plot, reject_plot), ('录取的志愿', '未录取的志愿'), loc='best', prop=font_prop)
# 显示图像
plt.grid()
plt.tight_layout()
# plt.show()
plt.savefig('专业与综合排名散点图.png', dpi=600)
