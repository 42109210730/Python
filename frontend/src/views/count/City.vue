<script setup lang="ts">
import * as echarts from "echarts"
import { onMounted, ref, onUnmounted, computed } from "vue"
import frontendData from '@/data/frontend.json'

const chart = ref<any>(null)

// 处理学历数据
const processDegreeData = computed(() => {
  // 学历要求统计
  const degreeMap: Record<string, number> = {}
  
  frontendData.forEach((job: any) => {
    // 统计学历要求
    if (job.jobDegree) {
      degreeMap[job.jobDegree] = (degreeMap[job.jobDegree] || 0) + 1
    }
  })
  
  const degreeData = Object.entries(degreeMap)
    .map(([name, value]) => ({ value, name }))
  
  return degreeData
})

const initPieChart = () => {
  const degreeChart = echarts.init(document.getElementById('degree-chart'))
  chart.value = degreeChart

  degreeChart.setOption({
    title: { 
      text: '学历要求分布', 
      textStyle: { color: '#fff' },
      left: 'center'
    },
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      left: 'left',
      textStyle: { color: '#fff' }
    },
    series: [{
      name: '学历要求',
      type: 'pie',
      radius: '60%',
      center: ['50%', '60%'],
      data: processDegreeData.value,
      label: { color: '#fff' },
      emphasis: {
        itemStyle: {
          shadowBlur: 10,
          shadowOffsetX: 0,
          shadowColor: 'rgba(0, 0, 0, 0.5)'
        }
      }
    }]
  });
}

// 添加窗口resize监听
const handleResize = () => {
  chart.value?.resize()
}

onMounted(() => {
  initPieChart()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  chart.value?.dispose()
})
</script>

<template>
  <div class="degree-container">
    <div class="chart-container">
      <div id="degree-chart"></div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.degree-container {
  height: 100vh;
  background-color: #0f1624;
  display: flex;
  justify-content: center;
  align-items: center;
  box-sizing: border-box;
  padding: 20px;
  
  .chart-container {
    width: 80%;
    height: 80%;
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    padding: 20px;
    
    #degree-chart {
      width: 100%;
      height: 100%;
    }
  }
}
</style>