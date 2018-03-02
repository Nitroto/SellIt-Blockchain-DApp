<template>
  <div class="container">
    <b-form @submit="onSubmit" @reset="onReset">
      <b-input-group prepend="Title">
        <b-form-input id="title"
                      type="text"
                      v-model="form.title"
                      required
                      placeholder="Enter title">
        </b-form-input>
      </b-input-group>

      <br/>

      <b-input-group prepend="Price">
        <b-form-input id="price"
                      type="number"
                      min="0"
                      v-model="form.price"
                      required
                      placeholder="Enter price">
        </b-form-input>
        <b-input-group-append>
          <b-form-select class="btn btn-outline-info" v-model="unit" :options="units"/>
        </b-input-group-append>
      </b-input-group>

      <br/>

      <b-input-group>
        <b-form-textarea id="description"
                         v-model="form.description"
                         required
                         placeholder="Enter description"
                         :rows="3"
                         :max-rows="6">
        </b-form-textarea>
      </b-input-group>
      <br/>
      <b-button type="submit" variant="primary">Submit</b-button>
      <b-button type="reset" variant="danger">Reset</b-button>
    </b-form>
  </div>
</template>

<script>
  export default {
    name: 'sell',
    data () {
      return {
        form: {
          title: '',
          description: '',
          price: 0
        },
        unit: 'wei',
        units: ['wei', 'gwei', 'finney', 'ether']
      }
    },
    methods: {
      onSubmit: function () {
        console.log('submited')
      },
      onReset: function () {
        this.$validator.reset()
      }
    }
  }
</script>

<style scoped>

</style>
