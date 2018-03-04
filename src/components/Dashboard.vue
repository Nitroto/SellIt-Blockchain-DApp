<template>
  <div class="container">
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
          <b-btn v-if="!offer[4]" v-b-modal.confirmModal @click="id = offer[0].toNumber()" variant="info">Buy now</b-btn>
        </b-card>
        <br/>
      </b-col>
    </b-row>

  </div>
</template>

<script>
  import Payment from '@/js/payment'
  import Converter from '@/js/converter'

  export default {
    name: 'dashboard',
    data () {
      return {
        offers: []
      }
    },
    computed: {},
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
          Payment.getOfferById(i).then(tx => {
            this.offers.push(tx)
          }, err => {
            console.log(err)
          })
        }
      }

    }
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
