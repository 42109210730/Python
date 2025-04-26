<template>
  <div class="job-search">
    <div class="search-controls">
      请选择职位类别：
      <el-select v-model="selectedCategory" class="category-select" placeholder="选择职位类别" @change="handleCategoryChange">
        <el-option label="前端开发" value="前端" />
        <el-option label="后端开发" value="后端" />
        <el-option label="软件测试" value="测试" />
      </el-select>
    </div>

    <div class="job-stats" v-if="jobData && !loading">
      <div class="stat-card" v-for="(value, label) in stats" :key="label">
        <div class="stat-number">{{ value }}</div>
        <div class="stat-label">{{ label }}</div>
      </div>
    </div>

    <div class="job-list-container">
      <div class="job-list" v-loading="loading">
        <el-empty v-if="!jobs.length && !loading" description="请选择职位类别或进行搜索" />
        <el-card v-for="job in jobs" :key="job.id" class="job-item">
          <div class="job-header">
            <h3 :class="{ 'favorited': job.isFavorite }">{{ job.job_name }}</h3>
            <el-button :type="job.isFavorite ? 'danger' : 'info'" @click="handleFavorite(job)"
              :loading="job.favoriteLoading">
              {{ job.isFavorite ? '取消收藏' : '收藏' }}
            </el-button>
          </div>
          <div class="job-info">
            <div class="job-details">
              <p>{{ job.company_name }}</p>
              <p>{{ job.company_size }}</p>
              <p class="salary">{{ job.salary }}</p>
              <p>{{ job.city }}</p>
              <p>{{ job.experience }}</p>
              <p>{{ job.degree }}</p>
            </div>
            <div class="job-tags">
              <el-tag v-for="(keyword, idx) in job.keywords" :key="idx" size="small">
                {{ keyword }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { favoriteJob, unfavoriteJob, getFavoriteJobs } from '../../api/job'

import frontendData from '@/data/frontend.json'
import backendData from '@/data/backend.json'
import testingData from '@/data/testing.json'
import { Job } from './types'

export default defineComponent({
  name: 'JobSearch',
  setup() {
    const selectedCategory = ref('前端')
    const jobData = ref<any>(null)
    const jobs = ref<Job[]>([])
    const loading = ref(false)
    const stats = ref<Record<string, string>>({
      职位数量: '0',
      热门学历要求: '本科',
      主要城市: '北京'
    })

    const CATEGORY_DATA_MAP: Record<string, any> = {
      '前端': frontendData,
      '后端': backendData,
      '测试': testingData
    }
    
    const favoritedJobIds = ref<Set<string>>(new Set())

    const loadFavoriteStatus = async () => {
      try {
        const res = await getFavoriteJobs({})
        if (res.code === 200) {
          favoritedJobIds.value = new Set(res.data.map((job: any) => job.id))
          jobs.value = jobs.value.map(job => ({
            ...job,
            isFavorite: favoritedJobIds.value.has(job.id)
          }))
        }
      } catch (error) {
        console.error('加载收藏状态失败:', error)
      }
    }

    const loadJobData = async () => {
      loading.value = true
      try {
        const data = CATEGORY_DATA_MAP[selectedCategory.value] || frontendData
        jobData.value = data
        jobs.value = data.map((item: any) => ({
          id: item.securityId,
          job_name: item.jobName,
          company_name: item.brandName,
          company_size: item.brandScaleName,
          salary: item.salaryDesc,
          city: item.cityName,
          experience: item.jobExperience || '不限',
          degree: item.jobDegree || '不限',
          keywords: item.skills || [],
          isFavorite: favoritedJobIds.value.has(item.securityId),
          favoriteLoading: false
        }))
        calculateStatistics()
        await loadFavoriteStatus()
      } catch (error) {
        console.error(error)
        ElMessage.error('加载数据失败')
      } finally {
        loading.value = false
      }
    }

    const handleFavorite = async (job: Job) => {
      job.favoriteLoading = true
      try {
        const action = job.isFavorite ? unfavoriteJob : favoriteJob
        const res = await action({ jobId: job.id }) 
        if (res.code === 200) {
          job.isFavorite = !job.isFavorite
          if (job.isFavorite) {
            favoritedJobIds.value.add(job.id)
          } else {
            favoritedJobIds.value.delete(job.id)
          }
          ElMessage.success(job.isFavorite ? '收藏成功' : '取消收藏成功')
        }
      } catch {
        ElMessage.error('操作失败，请重试')
      } finally {
        job.favoriteLoading = false
      }
    }

    const calculateStatistics = () => {
      const jobList = jobData.value || []
      const cityMap: Record<string, number> = {}
      const degreeMap: Record<string, number> = {}

      jobList.forEach((job: any) => {
        cityMap[job.cityName] = (cityMap[job.cityName] || 0) + 1
        const degree = job.jobDegree || '不限'
        degreeMap[degree] = (degreeMap[degree] || 0) + 1
      })

      const topCity = Object.entries(cityMap).sort((a, b) => b[1] - a[1])[0]?.[0] || '北京'
      const topDegree = Object.entries(degreeMap).sort((a, b) => b[1] - a[1])[0]?.[0] || '本科'

      stats.value = {
        可用职位: `${jobList.length}`,
        热门学历要求: topDegree,
        主要城市: topCity
      }
    }

    const handleCategoryChange = () => {
      loadJobData()
    }

    onMounted(loadJobData)

    return {
      selectedCategory,
      jobData,
      jobs,
      loading,
      handleFavorite,
      stats,
      handleCategoryChange
    }
  }
})
</script>

<style lang="scss" scoped>
$card-radius: 8px;
$card-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);

.job-search {
  display: flex;
  flex-direction: column;
  padding: 20px;
  height: 100vh;
  box-sizing: border-box;
}

.search-controls {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  align-items: center;
}

.category-select {
  width: 200px;
}

.job-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 10px;
}

.stat-card {
  background: #fff;
  border-radius: $card-radius;
  padding: 10px;
  box-shadow: $card-shadow;
  flex: 1;
  text-align: center;
}

.stat-number {
  font-size: 20px;
  font-weight: bold;
  color: #409EFF;
  margin-bottom: 5px;
}

.stat-label {
  color: #606266;
}

.job-list-container {
  flex: 1;
  min-height: 400px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: $card-radius;
  background-color: #f5f7fa;
  padding: 10px;
  margin-bottom: 5px;

  &::-webkit-scrollbar {
    width: 8px;
  }

  &::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  &::-webkit-scrollbar-thumb {
    background: #cccccc;
    border-radius: 4px;

    &:hover {
      background: #aaaaaa;
    }
  }
}

.job-list {
  display: grid;
  gap: 10px;
}

.job-item {
  border-radius: $card-radius;
  box-shadow: $card-shadow;
}

.job-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;

  h3 {
    font-size: 16px;
    // transition: color 0.3s ease;

    // &.favorited {
    //   color: #f56c6c;
    // }
  }
}

.job-info {
  color: #666;
  display: flex;
  flex-direction: column;
  gap: 10px;

  .job-details {
    display: flex;
    flex-direction: row;
    align-items: center;
    flex-wrap: wrap;
    gap: 15px;

    p {
      margin: 0;
      display: flex;
      align-items: center;

      &:not(:last-child):after {
        content: '|';
        margin-left: 15px;
        color: #dcdfe6;
      }
    }

    .salary {
      color: #f56c6c;
      font-weight: bold;
    }
  }

  .job-tags {
    margin-top: 10px;
    display: flex;
    gap: 5px;
    flex-wrap: wrap;
  }
}
</style>