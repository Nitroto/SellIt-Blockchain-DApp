<template>
  <b-container>
    <div><h3 class="float-left">Deposit balance: {{ deposit | currency('eth',5, {symbolOnLeft: false,
      spaceBetweenAmountAndSymbol: true}) }} (&asymp; {{ deposit * price | currency}})</h3></div>
    <div class="clearfix"></div>
    <div><h3 class="float-left">Pending payments: {{ pending | currency('eth',5, {symbolOnLeft: false,
      spaceBetweenAmountAndSymbol: true}) }} (&asymp; {{ pending * price | currency}})</h3></div>
    <div class="clearfix"></div>
    <br>
    <b-row>
      <b-col>
        <div id="deposit">
          <b-input-group>
            <b-input-group-prepend>
              <b-btn v-on:click="makeDeposit" variant="success">Deposit</b-btn>
            </b-input-group-prepend>

            <b-form-input type="number" min="0" v-model="depositValue"></b-form-input>

            <template slot="append">
              <b-form-select class="btn btn-outline-success" v-model="unitDeposit" :options="units"/>
            </template>
          </b-input-group>

          <p v-if="depositValue > 0">&asymp; {{ convertToUSD(convertToEth(depositValue, unitDeposit)) | currency('$', 3)
            }}</p>
        </div>
      </b-col>

      <b-col>
        <div id="withdraw">
          <b-input-group>
            <b-input-group-prepend>
              <b-btn v-on:click="withdraw" variant="info">Withdraw</b-btn>
            </b-input-group-prepend>

            <b-form-input type="number" min="0" v-model="withdrawValue"></b-form-input>

            <template slot="append">
              <b-form-select class="btn btn-outline-info" v-model="unitWithdraw" :options="units"/>
            </template>
          </b-input-group>
          <p v-if="withdrawValue > 0">
            &asymp; {{ convertToUSD(convertToEth(withdrawValue, unitWithdraw)) | currency('$',3) }}
          </p>
        </div>
      </b-col>
    </b-row>
    <br>

    <b-row>
      <b-col>
        <p v-if="buying.length > 0">Purchases</p>
        <div v-for="(offer, index) in buying" :key="index">
          <b-card border-variant="warning"
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
            <b-button-group>
              <b-btn @click="showModal(offer[0])" variant="info">Address</b-btn>
              <b-btn @click="confirmOffer(offer[0].toNumber())" variant="success" :disabled="offer[6] || offer[7]">
                Confirm
              </b-btn>
              <b-btn @click="cancelByBuyer(offer[0].toNumber())" variant="danger"
                     :disabled="offer[5] || offer[6] || offer[7]">Cancel
              </b-btn>
            </b-button-group>
          </b-card>
          <br/>
        </div>
      </b-col>
      <b-col>
        <p v-if="selling.length > 0">Sales</p>
        <div v-for="(offer, index) in selling" :key="index">
          <b-card border-variant="info"
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
            <b-button-group>
              <b-btn @click="showModal(offer[0])" variant="info" :disabled="!offer[4]">Address</b-btn>
              <b-btn @click="shippedOffer(offer[0].toNumber())" variant="primary"
                     :disabled="!offer[4] || offer[6] || offer[7]">Shipped
              </b-btn>
              <b-btn @click="cancelBySeller(offer[0].toNumber())" variant="danger"
                     :disabled="offer[5] || offer[6] || offer[7]">
                Cancel
              </b-btn>
            </b-button-group>


          </b-card>
          <br/>
        </div>

      </b-col>
    </b-row>

    <b-modal ref="addressModal" hide-footer title="Delivery to">
      <div class="d-block text-center">
        <h3> {{ address }}</h3>
      </div>
      <b-btn class="mt-3" variant="outline-danger" block @click="hideModal">Close</b-btn>
    </b-modal>
  </b-container>
</template>

<script>
  import Payment from '@/js/payment'
  import Converter from '@/js/converter'

  export default {
    name: 'user',
    data () {
      return {
        price: 0,
        deposit: 0,
        pending: 0,
        unitDeposit: 'wei',
        unitWithdraw: 'wei',
        depositValue: 0,
        withdrawValue: 0,
        units: ['wei', 'gwei', 'finney', 'ether'],
        selling: [],
        buying: [],
        address: ''
      }
    },
    created () {
      let url = 'https://min-api.cryptocompare.com/data/pricemulti?fsyms=ETH&tsyms=USD'
      this.$http.get(url).then(response => {
        this.price = response.data.ETH.USD
      }, () => {
        this.$toastr('error', 'There is some connection problem.', 'Error')
      })
      Payment.init().then(() => {
        this.updateBalances()
        this.getSellingOffers()
        this.getBuyingOffers()
      }, err => {
        console.log(err)
      })
    },
    methods: {
      convertToUSD: function (amount) {
        return Converter.toRealMoney(amount, this.price)
      },

      convertToEth: function (amount, unit) {
        return Converter.toEth(amount, unit)
      },

      makeDeposit: function () {
        let amountInWei = Converter.toWei(this.depositValue, this.unitDeposit)
        Payment.depositEther(amountInWei).then(() => {
          this.$toastr('success', 'You successfully deposit ' + Converter.toEth(this.depositValue, this.unitDeposit) + ' eth.', 'Success')
          this.updateBalances()
          this.unitDeposit = this.units[0]
          this.depositValue = 0
        }, err => {
          this.$toastr('error', 'There is some connection problem.', 'Error')
          console.log(err)
        })
      },

      withdraw: function () {
        let amountInWei = Converter.toWei(this.withdrawValue, this.unitWithdraw)
        Payment.withdrawEther(amountInWei).then(() => {
          this.$toastr('success', 'You successfully withdraw ' + Converter.toEth(this.withdrawValue, this.unitWithdraw) + ' eth.', 'Success')
          this.updateBalances()
          this.unitWithdraw = this.units[0]
          this.withdrawValue = 0
        }, err => {
          this.$toastr('error', 'There is some connection problem.', 'Error')
          console.log(err)
        })
      },

      getDepositBalance: function () {
        Payment.getDeposit().then(deposit => {
          this.deposit = this.convertToEth(deposit.toNumber(), 'wei')
        }, err => {
          this.$toastr('error', 'There is some problem.', 'Error')
          console.log(err)
        })
      },

      getBlockedBalance: function () {
        Payment.getPending().then(deposit => {
          this.pending = this.convertToEth(deposit.toNumber(), 'wei')
        }, err => {
          this.$toastr('error', 'There is some problem.', 'Error')
          console.log(err)
        })
      },

      updateBalances: function () {
        this.getDepositBalance()
        this.getBlockedBalance()
      },

      getIndexesSellingOffers: function () {
        return Payment.getIndexesOfSellingOffers()
      },

      getIndexeBuyingOffers: function () {
        return Payment.getIndexesOfBuyingOffers()
      },

      getSellingOffers () {
        let self = this
        this.getIndexesSellingOffers().then(result => {
          result.forEach(function (index) {
            Payment.getOfferById(index.toNumber()).then(offer => {
              Payment.getOfferStatus(index.toNumber()).then(statuses => {
                statuses.forEach(function (status) {
                  offer.push(status)
                })
                self.selling.push(offer)
              })
            }, err => {
              console.log(err)
            })
          })
        }, err => {
          console.log(err)
        })
      },

      getBuyingOffers () {
        let self = this
        this.getIndexeBuyingOffers().then(result => {
          result.forEach(function (index) {
            Payment.getOfferById(index.toNumber()).then(offer => {
              Payment.getOfferStatus(index.toNumber()).then(statuses => {
                statuses.forEach(function (status) {
                  offer.push(status)
                })
                self.buying.push(offer)
              })
            }, err => {
              console.log(err)
            })
          })
        }, err => {
          console.log(err)
        })
      },

      cancelByBuyer: function (id) {
        Payment.cancelOfferAsBuyer(id).then(res => {
          this.$toastr('warning', 'You cancel an offer.', 'Success')
          console.log(res)
        }, err => console.log(err))
      },

      cancelBySeller: function (id) {
        Payment.cancelOfferAsSeller(id).then(res => {
          this.$toastr('warning', 'You cancel an offer.', 'Success')
          console.log(res)
        }, err => console.log(err))
      },

      confirmOffer: function (id) {
        Payment.confirmOffer(id).then(res => {
          this.$toastr('success', 'You confirm an offer.', 'Success')
          console.log(res)
        }, err => console.log(err))
      },

      shippedOffer: function (id) {
        Payment.confirmShipping(id).then(res => {
          this.$toastr('success', 'You shipped an offer.', 'Success')
          console.log(res)
        }, err => console.log(err))
      },

      getShipmentAddress: function (id) {
        Payment.getShipmentAddress(id).then(address => {
        }, err => console.log(err))
      },

      showModal (id) {
        Payment.getShipmentAddress(id).then(address => {
          this.address = address.toString()
          this.$refs.addressModal.show()
        }, err => console.log(err))
      },

      hideModal () {
        this.$refs.addressModal.hide()
        this.address = ''
      }
    }
  }
</script>

<style scoped>

</style>
