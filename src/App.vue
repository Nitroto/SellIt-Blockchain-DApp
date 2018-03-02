<template>
  <div id="app">
    <b-navbar toggleable="md" type="dark" variant="secondary">

      <b-navbar-toggle target="nav_collapse"></b-navbar-toggle>

      <b-navbar-brand :to="{ name: 'dashboard'}">Sell<sup>it</sup></b-navbar-brand>

      <b-collapse is-nav id="nav_collapse">

        <b-navbar-nav>
          <b-nav-item :to="{ name: 'sell' }">Sell</b-nav-item>
          <b-nav-item :to="{ name: 'buy' }">Buy</b-nav-item>
        </b-navbar-nav>

        <!-- Right aligned nav items -->
        <b-navbar-nav class="ml-auto">
          <b-nav-form>
            <b-form-input size="sm"
                          class="mr-sm-2"
                          type="text"
                          placeholder="Search"/>
            <b-button size="sm" class="my-2 my-sm-0" type="submit">Search</b-button>
          </b-nav-form>

          <b-navbar-nav>
            <b-nav-item-dropdown v-if="userExists" right>
              <!-- Using button-content slot -->
              <template slot="button-content">
                <em>{{ pseudo}}</em>
              </template>
              <b-dropdown-item :to="{ name: 'user' }">Profile</b-dropdown-item>
              <b-dropdown-item @click="destroyAccount">Delete</b-dropdown-item>
            </b-nav-item-dropdown>
            <b-nav-item v-else :to="{ name: 'signup' }">Sign Up</b-nav-item>
          </b-navbar-nav>
        </b-navbar-nav>

      </b-collapse>
    </b-navbar>
    <br>
    <router-view></router-view>
  </div>
</template>

<script>
  import Users from '@/js/users'

  export default {
    name: 'app',
    data () {
      return {
        pseudo: undefined
      }
    },
    computed: {
      userExists: function () {
        return (typeof this.pseudo !== 'undefined')
      }
    },
    beforeCreate: function () {
      Users.init().then(() => {
        Users.exists(window.web3.eth.accounts[0]).then((exists) => {
          if (exists) {
            Users.authenticate().then(pseudo => {
              this.pseudo = pseudo
            })
          }
        })
      }).catch(err => {
        console.log(err)
      })
    },
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

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
  }
</style>
