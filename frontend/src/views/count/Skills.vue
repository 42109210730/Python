<script setup lang="ts">
import * as echarts from "echarts";
import "echarts-wordcloud";
import { onMounted, ref, onUnmounted, computed, watch } from "vue";

import frontendData from '@/data/frontend.json'
import backendData from '@/data/backend.json'
import testingData from '@/data/testing.json'

const skillsChart = ref<echarts.ECharts | null>(null);
const welfareChart = ref<echarts.ECharts | null>(null);
const selectedCategory = ref("前端");
const colorScheme = ref("random"); // 可选: random, palette, gradient, category
const welfareColorScheme = ref("random"); // 为福利词云设置单独的颜色方案

// 获取当前数据源
const getDataSource = () => {
  switch (selectedCategory.value) {
    case "前端":
      return frontendData;
    case "后端":
      return backendData;
    case "测试":
      return testingData;
    default:
      return frontendData;
  }
};

// 处理技能数据
const processSkillsData = computed(() => {
  const skillsMap: Record<string, number> = {};
  const dataSource = getDataSource();

  dataSource.forEach((job: any) => {
    if (job.skills && job.skills.length > 0) {
      job.skills.forEach((skill: string) => {
        skillsMap[skill] = (skillsMap[skill] || 0) + 1;
      });
    }
  });

  return Object.entries(skillsMap)
    .sort((a, b) => b[1] - a[1])
    .map(([name, value]) => ({
      name,
      value,
      textSize: Math.sqrt(value) * 2,
      category: getSkillCategory(name),
    }));
});

// 处理福利数据
const processWelfareData = computed(() => {
  const welfareMap: Record<string, number> = {};
  const dataSource = getDataSource();

  dataSource.forEach((job: any) => {
    if (job.welfareList && job.welfareList.length > 0) {
      job.welfareList.forEach((welfare: string) => {
        welfareMap[welfare] = (welfareMap[welfare] || 0) + 1;
      });
    }
  });

  return Object.entries(welfareMap)
    .sort((a, b) => b[1] - a[1])
    .map(([name, value]) => ({
      name,
      value,
      textSize: Math.sqrt(value) * 2,
      category: getWelfareCategory(name),
    }));
});

// 技能分类函数
const getSkillCategory = (skill: string): string => {
  const categories: Record<string, string[]> = {
    framework: ["Vue", "React", "Spring", "Django"],
    language: ["JavaScript", "TypeScript", "Java", "Python"],
    tool: ["Webpack", "Docker", "Postman", "Selenium"],
    database: ["MySQL", "Redis", "MongoDB"],
  };

  for (const [category, skills] of Object.entries(categories)) {
    if (skills.includes(skill)) return category;
  }
  return "other";
};

// 福利分类函数
const getWelfareCategory = (welfare: string): string => {
  const categories: Record<string, string[]> = {
    compensation: ["年终奖", "绩效奖金", "股票期权", "五险一金", "补充医疗保险", "餐补", "交通补助", "住房补贴", "通讯补贴"],
    workLife: ["带薪年假", "员工旅游", "定期体检", "零食下午茶", "团建聚餐"],
    bonus: ["全勤奖", "工龄奖", "加班补助", "节假日加班费", "法定节假日三薪"],
    facilities: ["免费班车", "有无线网", "包吃", "包住", "宿舍有空调"],
    other: ["节日福利", "生日福利", "定期体检", "意外险"]
  };

  for (const [category, items] of Object.entries(categories)) {
    if (items.some(item => welfare.includes(item))) return category;
  }
  return "other";
};

// 获取颜色方案
const getColorScheme = (scheme: string) => {
  return (data: any) => {
    const maxValue = Math.max(...data.map((item: any) => item.value));
    
    switch (scheme) {
      case "palette":
        const palette = [
          "#c23531", "#2f4554", "#61a0a8", "#d48265", "#91c7ae",
          "#749f83", "#ca8622", "#bda29a", "#6e7074", "#546570"
        ];
        return (params: any) => palette[params.dataIndex % palette.length];

      case "gradient":
        return (params: any) => {
          const ratio = params.data.value / maxValue;
          return `rgb(
            ${Math.floor(100 + 155 * ratio)},
            ${Math.floor(150 - 100 * ratio)},
            ${Math.floor(200 - 150 * ratio)}
          )`;
        };

      case "category":
        const skillCategoryColors: Record<string, string> = {
          framework: "#c23531", // 红色
          language: "#2f4554",  // 深蓝
          tool: "#61a0a8",      // 浅蓝
          database: "#d48265",  // 橙色
          other: "#91c7ae",     // 绿色
        };
        
        const welfareCategoryColors: Record<string, string> = {
          compensation: "#c23531", // 红色
          workLife: "#2f4554",     // 深蓝
          bonus: "#61a0a8",        // 浅蓝
          facilities: "#d48265",   // 橙色
          other: "#91c7ae",        // 绿色
        };
        
        return (params: any) => {
          if (params.data.category.includes("compensation") || params.data.category.includes("workLife")) {
            return welfareCategoryColors[params.data.category] || "#999";
          }
          return skillCategoryColors[params.data.category] || "#999";
        };

      case "random":
      default:
        return () =>
          `rgb(
            ${Math.round(Math.random() * 160 + 95)},
            ${Math.round(Math.random() * 160 + 95)},
            ${Math.round(Math.random() * 160 + 95)}
          )`;
    }
  };
};

// 初始化图表
const initCharts = () => {
  // 初始化技能词云图
  const skillsChartDom = document.getElementById("skills-chart");
  if (skillsChartDom) {
    skillsChart.value = echarts.init(skillsChartDom);
  }
  
  // 初始化福利词云图
  const welfareChartDom = document.getElementById("welfare-chart");
  if (welfareChartDom) {
    welfareChart.value = echarts.init(welfareChartDom);
  }
  
  updateCharts();
};

// 更新图表
const updateCharts = () => {
  updateSkillsChart();
  updateWelfareChart();
};

// 更新技能词云图
const updateSkillsChart = () => {
  if (!skillsChart.value) return;

  const skillsData = processSkillsData.value;
  const option = {
    title: {
      text: `${selectedCategory.value}--技术栈`,
      textStyle: { color: "#fff" },
      left: "center",
    },
    backgroundColor: "transparent",
    tooltip: {
      show: true,
      formatter: (params: any) => {
        return `${params.name}: 出现 ${params.value} 次<br/>
                分类: ${params.data.category || "未分类"}`;
      },
    },
    series: [
      {
        type: "wordCloud",
        shape: "circle",
        size: ["80%", "80%"],
        center: ["50%", "50%"],
        textStyle: {
          fontFamily: "sans-serif",
          fontWeight: "bold",
          color: getColorScheme(colorScheme.value)(skillsData),
          emphasis: {
            shadowBlur: 10,
            shadowColor: "#333",
          },
        },
        rotationRange: [-45, 45],
        gridSize: 8,
        drawOutOfBound: false,
        data: skillsData,
      },
    ],
  };

  skillsChart.value.setOption(option);
};

// 更新福利词云图
const updateWelfareChart = () => {
  if (!welfareChart.value) return;

  const welfareData = processWelfareData.value;
  const option = {
    title: {
      text: `${selectedCategory.value}--福利待遇`,
      textStyle: { color: "#fff" },
      left: "center",
    },
    backgroundColor: "transparent",
    tooltip: {
      show: true,
      formatter: (params: any) => {
        return `${params.name}: 出现 ${params.value} 次<br/>
                分类: ${params.data.category || "未分类"}`;
      },
    },
    series: [
      {
        type: "wordCloud",
        shape: "circle",
        size: ["80%", "80%"],
        center: ["50%", "50%"],
        textStyle: {
          fontFamily: "sans-serif",
          fontWeight: "bold",
          color: getColorScheme(welfareColorScheme.value)(welfareData),
          emphasis: {
            shadowBlur: 10,
            shadowColor: "#333",
          },
        },
        rotationRange: [-45, 45],
        gridSize: 8,
        drawOutOfBound: false,
        data: welfareData,
      },
    ],
  };

  welfareChart.value.setOption(option);
};

// 响应式调整
const handleResize = () => {
  skillsChart.value?.resize();
  welfareChart.value?.resize();
};

// 监听变化
watch([selectedCategory, colorScheme, welfareColorScheme], () => {
  updateCharts();
});

// 生命周期
onMounted(() => {
  initCharts();
  window.addEventListener("resize", handleResize);
});

onUnmounted(() => {
  window.removeEventListener("resize", handleResize);
  skillsChart.value?.dispose();
  welfareChart.value?.dispose();
});
</script>

<template>
  <div class="skills-container">
    <div class="controls">
      <div class="control-group">
        <label for="job-category">职位类别：</label>
        <select id="job-category" v-model="selectedCategory" class="control-input">
          <option value="前端">前端</option>
          <option value="后端">后端</option>
          <option value="测试">测试</option>
        </select>
      </div>
      
      <div class="control-group">
        <label for="skills-color-scheme">技能颜色：</label>
        <select id="skills-color-scheme" v-model="colorScheme" class="control-input">
          <option value="random">随机颜色</option>
          <option value="palette">调色板</option>
          <option value="gradient">频率渐变</option>
          <option value="category">按分类</option>
        </select>
      </div>
      
      <div class="control-group">
        <label for="welfare-color-scheme">福利颜色：</label>
        <select id="welfare-color-scheme" v-model="welfareColorScheme" class="control-input">
          <option value="random">随机颜色</option>
          <option value="palette">调色板</option>
          <option value="gradient">频率渐变</option>
          <option value="category">按分类</option>
        </select>
      </div>
    </div>
    
    <div class="charts-row">
      <div class="chart-container">
        <div id="skills-chart"></div>
      </div>
      
      <div class="chart-container">
        <div id="welfare-chart"></div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.skills-container {
  height: 100%;
  background-color: #0f1624;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;

  .controls {
    padding-top: 20px;
    padding-left: 20px;
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
    flex-wrap: wrap;

    .control-group {
      display: flex;
      align-items: center;
      gap: 8px;

      label {
        color: #fff;
        font-size: 14px;
        white-space: nowrap;
      }

      .control-input {
        background-color: rgba(255, 255, 255, 0.1);
        color: #fff;
        border: 1px solid rgba(255, 255, 255, 0.3);
        border-radius: 4px;
        padding: 8px 12px;
        font-size: 14px;
        cursor: pointer;
        transition: all 0.3s ease;
        min-width: 120px;

        &:hover {
          background-color: rgba(255, 255, 255, 0.2);
        }

        &:focus {
          outline: none;
          border-color: rgba(255, 255, 255, 0.5);
        }

        option {
          background-color: #1a2436;
          color: #fff;
        }
      }
    }
  }

  .charts-row {
    display: flex;
    flex: 1;
    // gap: 10px;
    
    .chart-container {
      flex: 1;
      width: 50%;
      background-color: #0f1624;
      border-radius: 8px;
      padding-top: 15px;
      
      #skills-chart,
      #welfare-chart {
        width: 102%;
        height: 102%;
      }
    }
  }
}

// @media (max-width: 1200px) {
//   .skills-container {
//     .charts-row {
//       flex-direction: column;
      
//       .chart-container {
//         width: 100%;
//         height: 50%;
//       }
//     }
//   }
// }

// @media (max-width: 768px) {
//   .skills-container {
//     padding: 10px;
    
//     .controls {
//       flex-direction: column;
//       gap: 10px;
      
//       .control-group {
//         width: 100%;
        
//         .control-input {
//           width: 100%;
//         }
//       }
//     }
    
//     .charts-row {
//       flex-direction: column;
//     //   gap: 20px;
      
//       .chart-container {
//         min-height: 300px;
//       }
//     }
//   }
// }
</style>