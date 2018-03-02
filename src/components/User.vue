<template>
  <b-container>
    <div><h3 class="float-left">Deposit balance: {{ deposit | currency('eth',0, {symbolOnLeft: false,
      spaceBetweenAmountAndSymbol: true}) }} ({{ deposit * price | currency}})</h3></div>
    <div class="clearfix"></div>
    <div><h3 class="float-left">Pending payments: {{ pending | currency('eth',0, {symbolOnLeft: false,
      spaceBetweenAmountAndSymbol: true}) }} ({{ pending * price | currency}})</h3></div>
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

          <p v-if="depositValue > 0">{{ convertToUSD(convertToEth(depositValue, unitDeposit)) | currency('$', 3) }}</p>
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
          <p v-if="withdrawValue > 0">{{ convertToUSD(convertToEth(withdrawValue, unitWithdraw)) | currency('$', 3)
            }}</p>
        </div>
      </b-col>
    </b-row>
    <br>
    <p> TODO: All active offers for user sell or buy</p>

  </b-container>

</template>

<script>
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
        units: ['wei', 'gwei', 'finney', 'ether']
      }
    },
    created () {
      let url = 'https://min-api.cryptocompare.com/data/pricemulti?fsyms=ETH&tsyms=USD'
      this.$http.get(url).then(response => {
        this.price = response.data.ETH.USD
      }, () => {
        this.$toastr('error', 'There is some connection problem.', 'Error')
      })
    },
    methods: {
      makeDeposit: function () {
        let amountInWei = this.convertToWei(this.depositValue, this.unitDeposit)
        this.unitDeposit = this.units[0]
        this.depositValue = 0
        this.$toastr('success', amountInWei, 'Td')
      },

      withdraw: function () {
        let amountInWei = this.convertToWei(this.depositValue, this.unitDeposit)
        this.unitWithdraw = this.units[0]
        this.withdrawValue = 0
        this.$toastr('success', amountInWei, 'Zemi')
      },

      convertToEth: function (amount, unit) {
        switch (unit) {
          case 'wei':
            return amount / 1000000000000000000
          case 'gwei':
            return amount / 1000000000
          case 'finney':
            return amount / 1000
          default:
            return amount
        }
      },

      convertToWei: function (amount, unit) {
        switch (unit) {
          case 'ether':
            return amount * 1000000000000000000
          case 'finney':
            return amount * 1000000000000000
          case 'gwei':
            return amount * 1000000000
          default:
            return amount
        }
      },

      convertToUSD: function (amount) {
        return amount * this.price
      }
    }
  }
</script>

<style scoped>

</style>
