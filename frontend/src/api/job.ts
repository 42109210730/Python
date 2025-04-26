import { post, get } from "../utils/request.ts";

// 收藏职位
export const favoriteJob = (data: object) => {
  return post("/my/jobs/collect/addJob", data);
};

// 取消收藏职位
export const unfavoriteJob = (data: object) => {
  return post("/my/jobs/collect/deleteJob", data);
};

// 获取已收藏职位
export const getFavoriteJobs = (data: object) => {
  return get("/my/jobs/collectList", data);
};

/**
 * 获取推荐职位列表
 * 根据用户画像和偏好推荐岗位
 * @param params 推荐参数 (可选: limit - 限制返回数量, keywords - 关键词过滤)
 */
export const getRecommendedJobs = (params: object = {}) => {
    return get("/my/jobs/recommendations", params);
  };
  
  /**
   * 获取职位详情
   * @param id 职位ID
   */
  export const getJobDetail = (id: string | number) => {
    return get(`/my/jobs/detail?id=${id}`);
  };
  
  /**
   * 搜索职位
   * @param params 搜索参数 (keywords, city, experience, degree, salary, page, pageSize)
   */
  export const searchJobs = (params: object) => {
    return get("/my/jobs/search", params);
  };
  
  /**
   * 查看热门职位
   * @param limit 限制条数，默认10条
   */
  export const getHotJobs = (limit: number = 10) => {
    return get(`/my/jobs/hot?limit=${limit}`);
  };