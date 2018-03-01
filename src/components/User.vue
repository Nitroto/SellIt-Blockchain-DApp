<template>
  <h1>User</h1>
</template>

<script>
  import Users from '@/js/users'

  export default {
    name: 'user',
    methods: {
      destroyAccount: function (e) {
        e.preventDefault()
        Users.destroy().then(() => {
          this.pseudo = undefined
        }).catch(err => {
          console.log(err)
        })
      }
    }
  }
</script>

<style scoped>

</style>
