<script lang="ts" setup>
import { ref, watch, onMounted } from "vue";
import type { FormInstance, FormRules } from "element-plus";
import { login, reguser, getLoginInfo } from "../api/user";
import { userStore } from "../store";
import { ElMessage } from "element-plus";
import router from "../router";

const ruleFormRef = ref<FormInstance>();
const isRegister = ref(false);
const checked = ref(false);

// 表单校验方法
// 验证账号
const validateName = (_: any, value: any, callback: any) => {
  if (value === "") {
    callback(new Error("用户名不能为空"));
  } else {
    callback();
  }
};
// 验证密码
const validatePwd = (_: any, value: any, callback: any) => {
  if (value === "") {
    callback(new Error("密码不能为空"));
  } else {
    callback();
  }
};
// 验证确认密码
const validateRePwd = (_: any, value: any, callback: any) => {
  if (value === "") {
    callback(new Error("确认密码不能为空"));
  } else if (value !== ruleForm.value.password) {
    callback(new Error("两次密码不一致"));
  } else {
    callback();
  }
};
const ruleForm = ref({
  username: "",
  password: "",
  repassword: "",
});
//验证对象
const rules = ref<FormRules<typeof ruleForm>>({
  username: [{ validator: validateName, trigger: "blur" }],
  password: [{ validator: validatePwd, trigger: "blur" }],
  repassword: [{ validator: validateRePwd, trigger: "blur" }],
});

const useData = userStore();

// 获取记住我信息
const userLoginDate = useData.userLogin;
ruleForm.value.username =
  userLoginDate.username === "" ? "" : userLoginDate.username;
ruleForm.value.password =
  userLoginDate.password === "" ? "" : userLoginDate.password;
checked.value = userLoginDate.checked;

// 登录方法
const userLogin = (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  formEl.validate(async (valid) => {
    if (valid) {
      // 请求登录接口
      await login(ruleForm.value).then(async (res: any) => {
        if (res.code === 200) {
          useData.setToken(res.token);
          const user = await getLoginInfo(ruleForm.value.username);
          console.log(user);
          useData.setData(user.data);
          //记住我
          if (checked.value) {
            useData.setUserLogin({
              username: ruleForm.value.username,
              password: ruleForm.value.password,
              checked: checked.value,
            });
          } else {
            useData.removeUserLogin();
          }
          ElMessage.success("登录成功");
          router.push("/index");
        } else {
          ElMessage.error("登录失败");
        }
      });
    } else {
      return false;
    }
  });
};
// 注册方法
const userRegister = (formEl: FormInstance | undefined) => {
  if (!formEl) return;
  formEl.validate(async (valid) => {
    if (valid) {
      // 请求注册接口
      await reguser(ruleForm.value).then((res: any) => {
        if (res.code === 200) {
          ElMessage.success("注册成功");
          isRegister.value = false;
        } else {
          ElMessage.error("注册失败");
        }
      });
    } else {
      return false;
    }
  });
};
// 切换的时候，重置表单内容
watch(isRegister, () => {
  ruleForm.value = {
    username: "",
    password: "",
    repassword: "",
  };
});
// 记住我事件
const checkedFun = (e: any) => {
  checked.value = e;
};
onMounted(() => {
  if (useData.token) {
    router.push("/index");
  }
});
</script>

<template>
  <el-row class="login-page">
    <el-col :span="6" class="bg"></el-col>
    <el-col :span="6" :offset="3" class="form">
      <div class="title">招聘信息多维度可视化与个性化推荐系统</div>
      <el-form-item prop="username" label="用户名">
        <el-input v-model="ruleForm.username" placeholder="请输入用户名"></el-input>
      </el-form-item>
      <el-form-item prop="password" label="密 码">
        <el-input v-model="ruleForm.password" type="password" placeholder="请输入密码"></el-input>
      </el-form-item>
      <!-- 注册相关表单 -->
      <el-form :model="ruleForm" :rules="rules" ref="ruleFormRef" size="large" autocomplete="off" v-if="isRegister">
        <el-form-item prop="repassword" label="确认密码">
          <el-input v-model="ruleForm.repassword" type="password" placeholder="请再次输入密码"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button @click="userRegister(ruleFormRef)" class="button" color="#ae9577" auto-insert-space>
            注册
          </el-button>
        </el-form-item>
        <el-link type="info" :underline="false" @click="isRegister = false">
          ← 返回
        </el-link>
      </el-form>

      <!-- 登录相关表单 -->
      <el-form :model="ruleForm" :rules="rules" ref="ruleFormRef" size="large" autocomplete="off" v-else>
        <el-form-item class="login-tip">
          <div class="login-tip">
            <el-checkbox v-model="checked" @change="checkedFun" text-color="#c6b5a0">记住我</el-checkbox>
            <el-link type="info" :underline="false" @click="isRegister = true">没有账号？</el-link>
          </div>
        </el-form-item>
        <el-form-item>
          <el-button @click="userLogin(ruleFormRef)" class="button" color="#ae9577" auto-insert-space>登录</el-button>
        </el-form-item>
        <el-link type="info" :underline="false" @click="isRegister = true">
          注册 →
        </el-link>
      </el-form>
    </el-col>
  </el-row>
</template>

<style lang="scss" scoped>
.login-page {
  background-image: url("../assets/login.jpg");
  background-size: cover;
  background-position: center;
  background-repeat: no-repeat;
  height: 100vh;
  width: 100%;
  display: flex;
  align-self: center;

  .form {
    background-color: rgba(255, 255, 255, 0.3);
    border-radius: 20px;
    padding: 30px;
    box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
    margin: auto;

    .title {
      text-align: center;
      font-size: 18px;
      font-weight: 500;
      font-family: Georgia, serif;
      margin-bottom: 30px;
      color: #b5623a;
    }

    .button {
      width: 100%;
      color: #ebe9e7;
    }

    .login-tip {
      width: 100%;
      display: flex;
      justify-content: space-between;
    }
  }
}

</style>
