<template>
    <div class="job-recommend">
      <h3>为您推荐</h3>
      <div class="recommended-jobs-container">
        <div class="recommended-jobs scrollable" v-loading="recommendLoading">
          <el-empty v-if="!recommendedJobs.length && !recommendLoading">
            <template #description>
              <p>暂无推荐职位</p>
            </template>
          </el-empty>
          
          <el-card v-for="job in recommendedJobs" :key="job.id" class="job-item recommendation">
            <div class="job-header">
              <div class="title-section">
                <h3>{{ job.job_name }}</h3>
                <el-tag v-if="job.recommendReason" type="success" size="small" class="reason-tag">
                  推荐理由: {{ job.recommendReason }}
                </el-tag>
              </div>
              <el-button type="primary" @click="addFavorite(job)" :loading="job.loading">
                收藏
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
  import { favoriteJob, getRecommendedJobs } from '../../api/job'
  import { ElMessage } from 'element-plus'
  import { Job } from './types'
  
  export default defineComponent({
    name: 'JobRecommend',
    setup() {
      const recommendedJobs = ref<Job[]>([])
      const recommendLoading = ref(false)
  
      const loadRecommendations = async () => {
        recommendLoading.value = true
        try {
          const res = await getRecommendedJobs({})
          if (res.code === 200) {
            recommendedJobs.value = res.data.map((job: any) => ({
              ...job,
              loading: false
            }))
          }
        } catch (error) {
          ElMessage.error('获取推荐职位失败')
        } finally {
          recommendLoading.value = false
        }
      }
      
      const addFavorite = async (job: any) => {
        job.loading = true
        try {
          const res = await favoriteJob({ jobId: job.id })
          if (res.code === 200) {
            ElMessage.success('收藏成功')
            // 从推荐列表中移除
            recommendedJobs.value = recommendedJobs.value.filter(j => j.id !== job.id)
          }
        } catch (error) {
          ElMessage.error('操作失败')
        } finally {
          job.loading = false
        }
      }
  
      onMounted(() => {
        loadRecommendations()
      })
  
      return {
        recommendedJobs,
        recommendLoading,
        addFavorite
      }
    }
  })
  </script>
  
  <style lang="scss" scoped>
  .job-recommend {
    padding: 20px;
    
    h2 {
      margin-bottom: 10px;
    }
  }
  
  .recommended-jobs-container {
    display: flex;
    flex-direction: column;
    gap: 15px;
  }
  
  .scrollable {
    max-height: 600px;
    overflow-y: auto;
    padding-right: 5px;
    
    &::-webkit-scrollbar {
      width: 6px;
    }
    
    &::-webkit-scrollbar-track {
      background: #f1f1f1;
      border-radius: 3px;
    }
    
    &::-webkit-scrollbar-thumb {
      background: #c1c1c1;
      border-radius: 3px;
    }
    
    &::-webkit-scrollbar-thumb:hover {
      background: #a8a8a8;
    }
  }
  
  .recommended-jobs {
    margin-top: 10px;
    display: grid;
    gap: 15px;
  }
  
  .job-item {
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    
    &.recommendation {
      border-left: 3px solid #67c23a;
    }
  }
  
  .job-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 5px;
  
    .title-section {
  display: flex;
  flex-direction: row;  
  align-items: center;  
  flex-wrap: wrap;      
  gap: 80px;           
  max-width: 80%;      
  
  h3 {
    margin: 0;
    font-size: 16px;
  }
  
  .reason-tag {
    font-size: 12px;
    height: auto;
    padding: 0 5px;
    line-height: 20px;
  }
}
  }

  
  .job-info {
    color: #666;
    display: flex;
    flex-direction: column;
    gap: 5px;
  
    .job-details {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
  
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