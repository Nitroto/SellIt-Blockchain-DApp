import Vue from 'vue'
import Router from 'vue-router'
import Dashboard from '@/components/Dashboard'
import Signup from '@/components/Signup'
import User from '@/components/User'
import Buy from '@/components/Buy'
import Sell from '@/components/Sell'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard
    },
    {
      path: '/signup',
      name: 'signup',
      component: Signup
    },
    {
      path: '/user',
      name: 'user',
      component: User
    },
    {
      path: '/buy',
      name: 'buy',
      component: Buy
    },
    {
      path: '/sell',
      name: 'sell',
      component: Sell
    }
  ]
})
