<template>
  <div class="container">
    <h3>Active offers</h3>
    <div id="offer">
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
            <b-btn v-b-modal.confirmModal block @click="id = offer[0].toNumber()" variant="info">
              Buy now
            </b-btn>
          </b-card>
          <br/>
        </b-col>
      </b-row>
    </div>
    <b-modal centered
             id="confirmModal"
             ref="modal"
             title="Order information"
             :data="data"
             @ok="handleConfirm(id)"
             @shown="clearForm">
      <form @submit.stop.prevent="handleConfirm">
        <p>Your deposit: {{ accountDeposit | currency('wei', 0, { symbolOnLeft: false,
          spaceBetweenAmountAndSymbol: true })}}</p>
        <!--<p>Offer price: {{ accountDeposit | currency('wei', 0, { symbolOnLeft: false,-->
          <!--spaceBetweenAmountAndSymbol: true })}}</p>-->
        <label for="deposit-input">Sum to deposit in wei</label>
        <b-form-input id="deposit-input"
                      type="number"
                      min="0"
                      v-model="deposit"
                      prepend="wei">
        </b-form-input>
        <label for="address">Delivery address</label>
        <b-form-input id="address"
                      type="text"
                      placeholder="Country, city, ect..."
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
        offers: [],
        deposit: 0,
        deliveryAddress: '',
        unit: 'wei',
        units: ['wei', 'gwei', 'finney', 'ether'],
        accountDeposit: 0,
        data: []
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
          this.getDepositBalance()
        })
      }, err => console.log(err))
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

      getDepositBalance: function () {
        Payment.getDeposit().then(balance => {
          this.accountDeposit = balance.toNumber()
        }, err => console.log(err))
      },

      getAllOffers: function (count) {
        Payment.getIndexesOfSellingOffers().then(indexes => {
          let result = []
          indexes.forEach(function (index) {
            result.push(index.toNumber())
          })
          for (let i = 1; i <= count; i++) {
            if (!result.includes(i)) {
              Payment.getOfferById(i).then(offer => {
                if (offer[4] === false) {
                  this.offers.push(offer)
                }
              }, err => {
                console.log(err)
              })
            }
          }
        }, err => console.log(err))
      },

      buyNow: function (id) {
        Payment.acceptOffer(id, this.deliveryAddress).then(() => {
          this.$toastr('success', 'You successfully pay for your purchase.', 'Success')
          this.$router.push('/user')
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
      }
    }
  }
</script>

<style scoped>

</style>
