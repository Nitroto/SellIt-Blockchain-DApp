<template>
  <div class="container">
    <h3>Active offers</h3>
    <div id="offer">
      <!--<b-input-group>-->
      <!--<b-input-group-prepend>-->
      <!--<b-btn v-on:click="getOffer" variant="info">Get Offer</b-btn>-->
      <!--</b-input-group-prepend>-->

      <!--<b-form-input type="number" min="1" v-model="offerId" placeholder="id"></b-form-input>-->
      <!--</b-input-group>-->
      <!--<br/>-->
      <h1 class="text-danger" v-if="offers.length === 0">There is no active offers</h1>
      <b-row>
        <b-col cols="6" v-for="(offer, index) in offers" :key="index">
          <b-card border-variant="success"
                  :header="offer[1]"
                  align="center">
            <div class="card-text">
              <p>
                {{ offer[2] }}
              </p>
              <p><strong>Price:</strong> {{ offer[3] | currency('wei', 0, { symbolOnLeft: false,
                spaceBetweenAmountAndSymbol: true }) }}</p>
              <p>&asymp; {{ convertToUSD(convertToEth(offer[3],'wei')) | currency('$', 2) }}</p>
            </div>
            <b-btn v-b-modal.confirmModal @click="id = offer[0].toNumber()" variant="info">Buy now</b-btn>
          </b-card>
          <br/>
        </b-col>
      </b-row>

    </div>

    <b-modal centered
             id="confirmModal"
             ref="modal"
             title="Order information"
             @ok="handleConfirm(id)"
             @shown="clearForm">
      <form @submit.stop.prevent="handleConfirm">
        <b-form-input type="number"
                      min="0"
                      placeholder="Sum to deposit"
                      v-model="deposit"
                      prepend="wei">
        </b-form-input>
        <br/>
        <b-form-input type="text"
                      placeholder="Address for delivery"
                      v-model="deliveryAddress">
        </b-form-input>
      </form>
    </b-modal>
  </div>
</template>

<script>
  import Payment from '@/js/payment'
  import Converter from '@/js/converter'

  export default {
    name: 'buy',
    data () {
      return {
        offerId: 1,
        offers: [],
        deposit: 0,
        deliveryAddress: '',
        unit: 'wei',
        units: ['wei', 'gwei', 'finney', 'ether'],
        _sellingIndexes: []
      }
    },
    created () {
      let url = 'https://min-api.cryptocompare.com/data/pricemulti?fsyms=ETH&tsyms=USD'
      this.$http.get(url).then(response => {
        this.rate = response.data.ETH.USD
      }, () => {
        this.$toastr('error', 'There is some connection problem.', 'Error')
      })

      Payment.init().then(() => {
        this.getNumberOfOffers().then(count => {
          this.getAllOffers(count.toNumber())
          this.getSellingOffers()
        })
      })
    },
    methods: {
      convertToEth: function (amount, unit) {
        return Converter.toEth(amount, unit)
      },

      convertToUSD: function (amount) {
        return Converter.toRealMoney(amount, this.rate)
      },

      getNumberOfOffers: function () {
        return Payment.getNumberOfOffers()
      },

      getAllOffers: function (count) {
        for (let i = 1; i <= count; i++) {
          Payment.getOfferById(i).then(offer => {
            if (offer[4] === false) {
              this.offers.push(offer)
            }
          }, err => {
            console.log(err)
          })
        }
      },

      buyNow: function (id) {
        Payment.acceptOffer(id, this.deliveryAddress).then(tx => {
          this.$toastr('success', 'You successfully pay for your purchase.', 'Success')
          console.log(tx)
          this.$router.push('/buy')
        }, err => {
          console.log(err)
          this.$toastr('error', 'There is some problem.', 'Error')
        })
        this.clearForm()
      },

      clearForm: function () {
        this.deposit = 0
        this.deliveryAddress = ''
      },

      handleConfirm: function (id) {
        console.log(id)
        if (this.deposit > 0) {
          Payment.depositEther(Converter.toWei(this.deposit, this.unit)).then(() => {
            this.$toastr('success', 'You successfully deposit ' + Converter.toEth(this.deposit, this.unit) + ' eth.', 'Success')
            this.$refs.modal.hide()
            this.buyNow(id)
          }, err => {
            this.$toastr('error', 'There is some problem.', 'Error')
            console.log(err)
          })
        } else {
          this.$refs.modal.hide()
          this.buyNow(id)
        }
      },

      getSellingOffers: function () {
        let self = this
        Payment.getIndexesOfSellingOffers().then(result => {
          result.forEach(function (index) {
            self._sellingIndexes.push(index.toNumber())
            console.log('blq')
          }, err => {
            console.log(err)
          })
        })
      }
    }
  }
</script>

<style scoped>

</style>
