<template>
  <b-row align-h="center">
    <b-col cols="6" align-self="center">
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
        <b-input-group prepend="Price" :append="convertToUSD(convertToEth(form.price,unit)) | currency('$',2)">
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
    </b-col>
  </b-row>
</template>

<script>
  import Converter from '@/js/converter'
  import Payment from '@/js/payment'

  export default {
    name: 'sell',
    data () {
      return {
        form: {
          title: '',
          description: '',
          price: 0
        },
        rate: 0,
        unit: 'wei',
        units: ['wei', 'gwei', 'finney', 'ether']
      }
    },
    created () {
      let url = 'https://min-api.cryptocompare.com/data/pricemulti?fsyms=ETH&tsyms=USD'
      this.$http.get(url).then(response => {
        this.rate = response.data.ETH.USD
      }, () => {
        this.$toastr('error', 'There is some connection problem.', 'Error')
      })

      Payment.init()
    },
    methods: {
      convertToEth: function (amount, unit) {
        return Converter.toEth(amount, unit)
      },

      convertToUSD: function (amount) {
        return Converter.toRealMoney(amount, this.rate)
      },

      onSubmit: function () {
        let priceInWei = Converter.toWei(this.form.price, this.unit)
        Payment.postOffer(this.form.title, this.form.description, priceInWei).then(tx => {
          this.$toastr('success', 'You have successfully published a new offer.', 'Success')
          this.form = {
            title: '',
            description: '',
            price: 0
          }
          this.$validator.reset()
          this.$router.replace('/')
        }, err => {
          console.log(err)
        })
      },

      onReset: function () {
        this.$validator.reset()
      },

      getNumberOfOffers: function () {
        Payment.getNumberOfOffers().then(count => {
          this.offersCount = count.toNumber()
        })
      }
    }
  }
</script>

<style scoped>

</style>
