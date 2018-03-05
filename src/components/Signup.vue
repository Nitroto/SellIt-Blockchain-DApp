<template>
  <section id='signup'>
    <h1>Sign up</h1>
    <b-row align-h="center">
      <b-col cols="8" align-self="center">
        <div class="w-75 p-3 mb-1 center">
          <b-form @submit="signup">
            <b-form-group id="signup" label="Username">
              <b-form-input id="username"
                            type="text"
                            v-model="form.pseudo"
                            required
                            placeholder="Enter your username">
              </b-form-input>
            </b-form-group>

            <b-button type="submit" block variant="outline-success">Sign Up</b-button>

          </b-form>
        </div>
      </b-col>
    </b-row>

  </section>
</template>

<script>
  import Users from '@/js/users'

  export default {
    name: 'signup',
    data () {
      return {
        form: {
          pseudo: undefined
        }
      }
    },
    beforeCreate: function () {
      Users.init()
    },
    methods: {
      signup: function () {
        let self = this
        if (typeof this.form.pseudo !== 'undefined' && this.form.pseudo !== '') {
          Users.create(this.form.pseudo).then(tx => {
            console.log(tx)
            self.$router.push('/')
          }).catch(err => {
            console.log(err)
          })
        }
      }
    }
  }
</script>

<style scoped>
  .center {
    margin: auto;
  }
</style>
