<template>
  <div class="job-collect">
    <h3>我的收藏</h3>
    <div class="collected-jobs-container">
      <div class="collected-jobs scrollable" v-loading="loading">
        <el-empty v-if="!favoriteJobs.length && !loading">
          <template #description>
            <p>暂无收藏职位</p>
          </template>
          <el-button type="primary" @click="viewMoreJobs">去浏览职位</el-button>
        </el-empty>

        <el-card v-for="job in favoriteJobs" :key="job.id" class="job-item">
          <div class="job-header">
            <h3 class="favorited">{{ job.job_name }}</h3>
            <el-button type="danger" @click="removeFavorite(job)" :loading="job.loading">
              取消收藏
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
import { getFavoriteJobs, unfavoriteJob } from '../../api/job'
import { ElMessage } from 'element-plus'
import { useRouter } from 'vue-router' // 添加路由钩子
import { Job } from './types'

export default defineComponent({
  name: 'JobCollect',
  setup() {
    const router = useRouter()
    const favoriteJobs = ref<Job[]>([])
    const loading = ref(false)

    const loadFavorites = async () => {
      loading.value = true
      try {
        const res = await getFavoriteJobs({})
        if (res.code === 200) {
          favoriteJobs.value = res.data.map((job: any) => ({
            ...job,
            loading: false
          }))
        }
      } catch (error) {
        ElMessage.error('获取收藏失败')
      } finally {
        loading.value = false
      }
    }

    const removeFavorite = async (job: any) => {
      job.loading = true
      try {
        const res = await unfavoriteJob({ jobId: job.id })  
        if (res.code === 200) {
          ElMessage.success('取消收藏成功')
          favoriteJobs.value = favoriteJobs.value.filter(j => j.id !== job.id)
        }
      } catch (error) {
        ElMessage.error('操作失败')
      } finally {
        job.loading = false
      }
    }    // 添加查看更多职位的方法
    const viewMoreJobs = () => {
      router.push('/index/search')
    }

    onMounted(() => {
      loadFavorites()
    })

    return {
      favoriteJobs,
      loading,
      removeFavorite,
      viewMoreJobs
    }
  }
})
</script>

<style lang="scss" scoped>
.job-collect {
  padding: 20px;
}

.collected-jobs-container {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-top: 20px;
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

.collected-jobs {
  display: grid;
  gap: 10px;
}

.job-item {
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.job-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;

  h3 {
    margin: 0;
    font-size: 16px;

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