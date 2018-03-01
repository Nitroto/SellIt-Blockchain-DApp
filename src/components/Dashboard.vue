<template>
  <div class="dashboard">
    <h1>{{ msg }}</h1>
  </div>
</template>

<script>
  export default {
    name: 'dashboard',
    data () {
      return {
        msg: 'This is dApp Dashboard page',
        pseudo: undefined
      }
    },
    computed: {},
    beforeCreate: function () {
    },
    methods: {}
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  h1, h2 {
    font-weight: normal;
    display: block;
  }

  ul {
    list-style-type: none;
    padding: 0;
  }

  li {
    display: inline-block;
    margin: 0 10px;
  }

  a {
    color: #42b983;
  }
</style>
