<script setup lang="ts">
import {
  User,
  DishDot,
  Service,
  GobletFull,
  Watch,
  QuartzWatch,
  Basketball,
} from "@element-plus/icons-vue";
import { userStore } from "../../store";

const useStore = userStore();

</script>

<template>
  <el-scrollbar>
    <el-menu
      router
      :default-active="$route.path"
      active-text-color="#ffd04b"
      background-color="#142334"
      class="el-menu-vertical-demo"
      text-color="#fff"
      style="border-right: none"
    >
      <!-- 只有超级管理员(roleId=1)可见 -->
      <el-sub-menu v-if="useStore.userData.roleId === 1" index="1">
        <template #title>
          <el-icon><User /></el-icon>
          超级管理员
        </template>
        <el-menu-item index="/index/user"
          ><el-icon><GobletFull /></el-icon>用户管理</el-menu-item
        >
      </el-sub-menu>

      <el-sub-menu index="2">
        <template #title>
          <el-icon><DishDot /></el-icon>
          <span>个人信息</span>
        </template>
        <el-menu-item index="/index/mine"
          ><el-icon><Watch /></el-icon>个人中心</el-menu-item
        >
        <el-menu-item index="/index/setPwd"
          ><el-icon><QuartzWatch /></el-icon>修改密码</el-menu-item
        >
      </el-sub-menu>
      <el-sub-menu index="3">
        <template #title>
          <el-icon><DishDot /></el-icon>
          <span>岗位信息</span>
        </template>
        <el-menu-item index="/index/search"
          ><el-icon><Watch /></el-icon>岗位查询</el-menu-item
        >
        <el-menu-item index="/index/collect"
          ><el-icon><QuartzWatch /></el-icon>我的收藏</el-menu-item
        >
        <el-menu-item index="/index/recommend"
          ><el-icon><Watch /></el-icon>岗位推荐</el-menu-item
        >
      </el-sub-menu>

      <el-sub-menu index="4">
        <template #title>
          <el-icon><Service /></el-icon>
          <span>统计信息</span>
        </template>
        <el-menu-item index="/index/analysis"
          ><el-icon><Basketball /></el-icon>可视化分析</el-menu-item
        >
        <!-- <el-menu-item index="/index/city"
          ><el-icon><Basketball /></el-icon>城市</el-menu-item
        > -->
        <el-menu-item index="/index/degree"
          ><el-icon><Basketball /></el-icon>学历饼状图</el-menu-item
        >
        <!-- <el-menu-item index="/index/experience"
          ><el-icon><Basketball /></el-icon>工作经验</el-menu-item
        > -->
        <el-menu-item index="/index/keyword"
          ><el-icon><Basketball /></el-icon>词云统计图</el-menu-item
        >
      </el-sub-menu>
    </el-menu>
  </el-scrollbar>
</template>

<style lang="scss" scoped></style>
