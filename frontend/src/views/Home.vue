<script setup lang="ts">
import * as echarts from "echarts"
import { onMounted, ref, onUnmounted, computed, watch } from "vue"
import frontendData from '@/data/frontend.json'
import backendData from '@/data/backend.json'
import testingData from '@/data/testing.json'
import cityToProvince from '@/utils/cityToProvince.ts'

// Data source mapping
const dataSources = {
  frontend: frontendData,
  backend: backendData,
  testing: testingData,
  all: [...frontendData, ...backendData, ...testingData] // Combined data for "all" option
}

const charts = ref<any>([])
const selectedCategory = ref<string>("all") // Track selected job category/data source

// 处理职位数据 - 基于选择的数据源
const processJobData = computed(() => {
  // 城市数据统计
  const cityMap: Record<string, number> = {}
  // 薪资范围统计 (分段统计)
  const salaryRanges = {
    '0-5K': 0,
    '5-10K': 0,
    '10-15K': 0,
    '15-20K': 0,
    '20K以上': 0
  }
  // 职业经验要求统计
  const experienceMap: Record<string, number> = {}

  // Get data based on selected category (now acts as data source selector)
  const currentData = dataSources[selectedCategory.value as keyof typeof dataSources] || dataSources.all

  currentData.forEach((job: any) => {
    // 统计城市分布
    if (job.cityName) {
      cityMap[job.cityName] = (cityMap[job.cityName] || 0) + 1
    }

    // 统计薪资范围
    if (job.salaryDesc) {
      const salary = job.salaryDesc.split('-');
      if (salary.length >= 2) {
        const maxSalary = parseInt(salary[1])

        if (maxSalary <= 5) {
          salaryRanges['0-5K']++
        } else if (maxSalary <= 10) {
          salaryRanges['5-10K']++
        } else if (maxSalary <= 15) {
          salaryRanges['10-15K']++
        } else if (maxSalary <= 20) {
          salaryRanges['15-20K']++
        } else {
          salaryRanges['20K以上']++
        }
      }
    }

    // 统计经验要求
    if (job.jobExperience) {
      experienceMap[job.jobExperience] = (experienceMap[job.jobExperience] || 0) + 1
    }
  })

  // 排序获取排名靠前的数据
  const topCities = Object.entries(cityMap)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 5)
    .map(([name, value]) => ({ name, value }))

  const experienceData = Object.entries(experienceMap)
    .sort((a, b) => b[1] - a[1])
    .map(([name, value]) => ({ name, value }))

  // 生成地图数据
  const mapData = Object.entries(cityMap)
    .map(([name, value]) => ({ name, value }))

    const salaryTrends = {
  xAxis: ['应届生', '1-3年', '3-5年', '5-10年', '10年以上'],
  series: [
    {
      name: '平均薪资下限',
      data: selectedCategory.value === 'frontend' ? 
            [6, 10, 15, 20, 28] :
            selectedCategory.value === 'backend' ?
            [7, 12, 18, 25, 32] :
            selectedCategory.value === 'testing' ?
            [5, 7, 10, 15, 20] :
            [5, 8, 12, 18, 25] // default for 'all'
    },
    {
      name: '平均薪资上限',
      data: selectedCategory.value === 'frontend' ? 
            [10, 18, 25, 35, 45] :
            selectedCategory.value === 'backend' ?
            [12, 20, 30, 40, 50] :
            selectedCategory.value === 'testing' ?
            [8, 12, 18, 25, 35] :
            [8, 15, 20, 30, 40] // default for 'all'
    }
  ]
}

  return {
    barData: topCities,
    mapData: mapData,
    experienceData: experienceData,
    lineData: salaryTrends,
    salaryRanges: salaryRanges
  }
})

const initCharts = async () => {
  const leftTopChart = echarts.init(document.getElementById('left-top-chart'))
  const leftMiddleChart = echarts.init(document.getElementById('left-middle-chart'))
  const centerChart = echarts.init(document.getElementById('center-chart'))
  const rightTopChart = echarts.init(document.getElementById('right-top-chart'))
  const rightMiddleChart = echarts.init(document.getElementById('right-middle-chart'))

  charts.value = [leftTopChart, leftMiddleChart, centerChart,
    rightTopChart, rightMiddleChart]

  initLineChart(leftTopChart)
  initBarChart(leftMiddleChart)
  initMapChart(centerChart)
  initPieChart(rightTopChart) 
  initBarChart(rightMiddleChart, true)
}

const initPieChart = (chart: any) => {
  const salaryRangesData = processJobData.value.salaryRanges;
    const pieData = Object.entries(salaryRangesData).map(([name, value]) => ({
    name,
    value
  }));

  chart.setOption({
    title: {
      text: `薪资分布`,
      textStyle: { color: '#fff', fontSize: 16, fontWeight: 'normal' },
      left: 'center'
    },
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: '5%',
      top: 'center',
      textStyle: { color: '#fff' }
    },
    backgroundColor: 'transparent',
    series: [{
      name: '薪资范围',
      type: 'pie',
      radius: '40%',
      center: ['40%', '50%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#0f1624',
        borderWidth: 2
      },
      label: {
        color: '#fff'
      },
      emphasis: {
        label: {
          show: true,
          fontSize: '14',
          fontWeight: 'bold'
        },
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      },
      // labelLine: {
      //   show: true
      // },
      data: pieData,
    }]
  });
}
const initBarChart = (chart: any, useAltData = false) => {
  const data = useAltData ? processJobData.value.experienceData : processJobData.value.barData;

  // Add category-specific title
  // const categoryText = {
  //   'all': '全部',
  //   'frontend': '前端',
  //   'backend': '后端',
  //   'testing': '测试'
  // }[selectedCategory.value] || '全部';

  chart.setOption({
    title: {
      // text: useAltData ? `${categoryText}--经验要求分布` : `${categoryText}--热门城市分布`, 
      text: useAltData ? `工作经验 - 职位数量` : `热门城市 - 职位数量`,
      textStyle: { color: '#fff', fontSize: 16, fontWeight: 'normal' },
    },
    tooltip: {},
    backgroundColor: 'transparent',
    xAxis: {
      data: data.map(item => item.name),
      axisLabel: { color: '#fff' }
    },
    yAxis: { axisLabel: { color: '#fff' } },
    series: [{
      name: '职位数量',
      type: 'bar',
      data: data.map(item => item.value)
    }]
  });
}

const initMapChart = (chart: any) => {

  // 创建按省份聚合的数据
  const provinceData: Record<string, number> = {}

  // 聚合城市数据到省级
  processJobData.value.mapData.forEach(item => {
    const province = cityToProvince[item.name]
    if (province) {
      provinceData[province] = (provinceData[province] || 0) + item.value
    }
  })

  // 转换为地图需要的数据格式
  const mapFormattedData = Object.entries(provinceData).map(([name, value]) => ({
    name: name + (name === '北京' || name === '上海' || name === '天津' || name === '重庆' ? '市' : '省'),
    value
  }))

  // 加载地图
  fetch('https://geo.datav.aliyun.com/areas_v3/bound/100000_full.json')
    .then(response => response.json())
    .then(chinaJSON => {
      echarts.registerMap('china', chinaJSON);

      chart.setOption({
        title: {
          text: `省市 - 职位数量`,
          textStyle: { color: '#fff', fontSize: 16, fontWeight: 'normal' },
        },
        backgroundColor: 'transparent',
        tooltip: {
          trigger: 'item',
          formatter: '{b}: {c}个职位'
        },
        visualMap: {
          left: 'left',
          min: 0,
          max: Math.max(...Object.values(provinceData), 1),
          text: ['高', '低'],
          textStyle: { color: '#fff' },
          inRange: { color: ['#50a3ba', '#eac736', '#d94e5d'] },
          calculable: true
        },
        series: [{
          name: '职位数量',
          type: 'map',
          map: 'china',
          roam: true,
          emphasis: {
            label: { show: true },
            itemStyle: { areaColor: '#2a333d' }
          },
          itemStyle: {
            areaColor: '#323c48',
            borderColor: '#111'
          },
          data: mapFormattedData // 使用映射后的省级数据
        }]
      });
    })
    .catch(error => {
      console.error('加载地图数据失败:', error);
      chart.setOption({
        title: {
          text: '地图加载失败',
          textStyle: { color: '#fff' },
          left: 'center',
          top: 'center'
        },
        backgroundColor: 'transparent'
      });
    });
}

const initLineChart = (chart: any, useAltData = false) => {
  const data = processJobData.value.lineData;

  chart.setOption({
    title: {
      text: `工作经验 - 薪资`,
      textStyle: { color: '#fff', fontSize: 16, fontWeight: 'normal' },
      left: 'center'
    },
    tooltip: {},
    legend: {
      data: data.series.map(item => item.name),
      textStyle: { color: '#fff' },
      top: '30px'
    },
    backgroundColor: 'transparent',
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      top: '70px',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: data.xAxis,
      axisLabel: {
        color: '#fff',
        rotate: useAltData ? 0 : 30
      },
      axisLine: {
        lineStyle: { color: '#555' }
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        color: '#fff',
        formatter: '{value}K'
      },
      splitLine: {
        lineStyle: { color: 'rgba(255, 255, 255, 0.1)' }
      },
      axisLine: {
        lineStyle: { color: '#555' }
      }
    },
    series: data.series.map((item, index) => ({
      name: item.name,
      type: 'line',
      smooth: true,
      data: item.data,
      symbol: 'circle', // 数据点形状
      symbolSize: 8,    // 数据点大小
      itemStyle: {
        borderWidth: 2
      },
      lineStyle: {
        width: 3
      },
      areaStyle: {
        // 添加渐变色区域
        opacity: 0.15,
        color: {
          type: 'linear',
          x: 0,
          y: 0,
          x2: 0,
          y2: 1,
          colorStops: [{
            offset: 0, color: index === 0 ? '#50a3ba' : '#d94e5d'
          }, {
            offset: 1, color: 'rgba(0, 0, 0, 0)'
          }]
        }
      },
      emphasis: {
        itemStyle: {
          borderWidth: 3,
          shadowBlur: 10,
          shadowColor: 'rgba(255, 255, 255, 0.5)'
        }
      }
    }))
  });
}

// Watch for category changes and update charts
const updateAllCharts = () => {
  charts.value.forEach((chart, index) => {
    if (index === 0) {
      initLineChart(chart);
    } else if (index === 1) {
      initBarChart(chart);
    } else if (index === 2) {
      initMapChart(chart);
    } else if (index === 3) {
      initPieChart(chart);
    } else if (index === 4) {
      initBarChart(chart, true);
    }
  });
};

watch(selectedCategory, () => {
  updateAllCharts();
});

// 添加窗口resize监听
const handleResize = () => {
  charts.value.forEach((chart: any) => chart?.resize())
}

onMounted(() => {
  initCharts()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  charts.value.forEach((chart: any) => chart?.dispose())
})
</script>

<template>
  <div class="screen-container">
    <div class="category-filter">
      <label>职位类别：</label>
      <select v-model="selectedCategory" class="select-control">
        <option value="all">全部</option>
        <option value="frontend">前端</option>
        <option value="backend">后端</option>
        <option value="testing">测试</option>
      </select>
    </div>

    <div class="charts-area">
      <div class="left-panel">
        <div class="chart-container">
          <div id="left-top-chart"></div>
        </div>
        <div class="chart-container">
          <div id="left-middle-chart"></div>
        </div>
      </div>

      <div class="center-panel">
        <div id="center-chart"></div>
      </div>

      <div class="right-panel">
        <div class="chart-container">
          <div id="right-top-chart"></div>
        </div>
        <div class="chart-container">
          <div id="right-middle-chart"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.screen-container {
  height: 100vh;
  background-color: #0f1624;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  padding: 20px;

  .category-filter {
    margin-bottom: 10px;
    display: flex;
    align-items: center;

    label {
      color: #fff;
      margin-right: 10px;
      font-size: 16px;
    }

    .select-control {
      background-color: #1a2133;
      color: #fff;
      border: 1px solid #2c3e50;
      border-radius: 4px;
      padding: 8px 12px;
      font-size: 14px;
      outline: none;
      cursor: pointer;

      &:hover {
        background-color: #2c3e50;
      }

      option {
        background-color: #1a2133;
      }
    }
  }

  .charts-area {
    display: flex;
    height: calc(100% - 50px);
    gap: 5px;

    .left-panel,
    .right-panel {
      flex: 1;
      height: 100%;
      display: flex;
      flex-direction: column;
      gap: 5px;

      .chart-container {
        flex: 1;
        background-color: rgba(0, 0, 0, 0.2);
        border-radius: 4px;
        padding: 10px;

        #left-top-chart,
        #left-middle-chart,
        #right-top-chart,
        #right-middle-chart {
          width: 100%;
          height: 100%;
        }
      }
    }

    .center-panel {
      flex: 1.5;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.2);
      border-radius: 4px;
      padding: 10px;

      #center-chart {
        width: 95%;
        height: 95%;
      }
    }
  }
}
</style>