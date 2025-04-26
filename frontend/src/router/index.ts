import { createRouter, createWebHistory } from "vue-router";
import { userStore } from "../store";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/login",
      redirect: "/",
    },
    {
      path: "/",
      name: "登录",
      meta: { title: "登录" },
      component: () => import("../views/Login.vue"),
    },
    {
      path: "/index",
      name: "首页",
      meta: { title: "首页" },
      component: () => import("../views/Index.vue"),
      children: [
        {
          path: "",
          name: "主页",
          meta: { title: "主页" },
          component: () => import("../views/Home.vue"),
        },
        {
          path: "user",
          name: "用户管理",
          meta: {
            title: "用户管理",
            requiresAdmin: true, // 添加需要管理员权限的标记
          },
          component: () => import("../views/user/user.vue"),
        },
        {
          path: "mine",
          name: "个人中心",
          meta: { title: "个人中心" },
          component: () => import("../views/user/Mine.vue"),
        },
        {
          path: "setPwd",
          name: "修改密码",
          meta: { title: "修改密码" },
          component: () => import("../views/user/SetPwd.vue"),
        },
        {
          path: "analysis",
          name: "数据分析",
          meta: { title: "数据分析" },
          component: () => import("../views/Home.vue"),
        },
        {
          path: "city",
          name: "城市",
          meta: { title: "城市" },
          component: () => import("../views/count/City.vue"),
        },
        {
          path: "degree",
          name: "学历",
          meta: { title: "学历" },
          component: () => import("../views/count/Degree.vue"),
        },
        {
          path: "experience",
          name: "工作经验",
          meta: { title: "工作经验" },
          component: () => import("../views/count/Experience.vue"),
        },
        {
          path: "keyword",
          name: "词云统计图",
          meta: { title: "词云统计图" },
          component: () => import("../views/count/Skills.vue"),
        },
        {
          path: "search",
          name: "岗位查询",
          meta: { title: "岗位查询" },
          component: () => import("../views/job/JobSearch.vue"),
        },
        {
          path: "collect",
          name: "我的收藏",
          meta: { title: "我的收藏" },
          component: () => import("../views/job/JobCollect.vue"),
        },
        {
          path: "recommend",
          name: "岗位推荐",
          meta: { title: "岗位推荐" },
          component: () => import("../views/job/JobRecommend.vue"),
        },
      ],
    },
  ],
});

// 添加路由守卫
router.beforeEach((to, from, next) => {
  const useStore = userStore();

  // 需要管理员权限的路由
  if (to.meta.requiresAdmin) {
    // 检查用户角色
    if (useStore.userData.roleId === 1) {
      next();
    } else {
      // 非管理员重定向到首页
      next("/index");
    }
  } else {
    next();
  }
});

export default router;
