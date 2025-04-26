<script setup lang="ts">
import * as echarts from "echarts"
import { onMounted, ref, onUnmounted, computed, watch } from "vue"
import frontendData from '@/data/frontend.json'
import backendData from '@/data/backend.json'
import testingData from '@/data/testing.json'

// Data source mapping
const dataSources = {
    frontend: frontendData,
    backend: backendData,
    testing: testingData
}

const chart = ref<any>(null)
const selectedCategory = ref<string>("all") // Track selected category
const selectedDataSource = ref<string>("frontend") // Track selected data source

// Get current data based on selected source
const getCurrentData = computed(() => {
    return dataSources[selectedDataSource.value as keyof typeof dataSources] || frontendData
})

// 处理学历数据
const processDegreeData = computed(() => {
    // 学历要求统计
    const degreeMap: Record<string, number> = {}

    // Get current data source
    const currentData = getCurrentData.value

    // Filter data based on selected category
    const filteredData = selectedCategory.value === "all"
        ? currentData
        : currentData.filter((job: any) => job.jobCategory === selectedCategory.value)

    filteredData.forEach((job: any) => {
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

    updateChart()
}

const updateChart = () => {
    if (!chart.value) return

    // Get title based on data source
    const chartTitle = {
        frontend: '前端--学历要求分布',
        backend: '后端--学历要求分布',
        testing: '测试--学历要求分布'
    }[selectedDataSource.value] || '学历要求分布'

    chart.value.setOption({
        title: {
            text: chartTitle,
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
            //   radius: ['40%', '70%'], // 设置为环形图
            //   center: ['40%', '50%'],
            data: processDegreeData.value,
            label: {
                color: '#fff',
                show: true,
                formatter: '{b}: {d}%',
            },
            emphasis: {
                itemStyle: {
                    shadowBlur: 10,
                    shadowOffsetX: 0,
                    shadowColor: 'rgba(0, 0, 0, 0.5)'
                }
            },
            // color: ['#50a3ba', '#91c7ae', '#eac736', '#dd6b66', '#d94e5d']

        }]
    })
}

// Watch for data source or category changes and update chart
watch([selectedDataSource, selectedCategory], () => {
    updateChart()
})

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
        <div class="filters">
            <div class="data-source-filter">
                <label>职位类别：</label>
                <select v-model="selectedDataSource" class="select-control">
                    <option value="frontend">前端</option>
                    <option value="backend">后端</option>
                    <option value="testing">测试</option>
                </select>
            </div>
        </div>

        <div class="chart-container">
            <div id="degree-chart"></div>
        </div>
    </div>
</template>

<style scoped lang="scss">
.degree-container {
    height: 100vh;
    background-color: #0f1624;
    padding: 20px;

    .filters {
        width: 100%;
        display: flex;
        justify-content: flex-start;
        margin-bottom: 20px;

        .data-source-filter {
            display: flex;
            align-items: center;

            label {
                color: #fff;
                margin-right: 8px;
                font-size: 14px;
            }
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

    .chart-container {
        width: 100%;
        height: 75%;
        background-color: #0f1624;
        border-radius: 8px;
        padding: 40px 120px;

        #degree-chart {
            width: 100%;
            height: 100%;
        }
    }
}
</style>
