<template>
  <div class="container">
    <h3>TODO: List all possible offers</h3>
    <div id="offer">
      <b-input-group>
        <b-input-group-prepend>
          <b-btn v-on:click="getOffer" variant="info">Get Offer</b-btn>
        </b-input-group-prepend>

        <b-form-input type="number" min="1" v-model="offerId" placeholder="id"></b-form-input>
      </b-input-group>
      <br/>

      <b-row>
        <b-col cols="6" v-for="offer in offers" :key="offer">
          <b-card border-variant="success"
                  :header="offer[0]"
                  header-text-variant="white"
                  align="center">
            <div class="card-text">
              <p>
                {{ offer[1] }}
              </p>
              confirmed: {{ offer[2] }}
              canceled: {{ offer[3] }}
              buyer: {{ offer[4] }}
            </div>
          </b-card>
          <br/>
        </b-col>
      </b-row>

    </div>
  </div>
</template>

<script>
  import Payment from '@/js/payment'

  export default {
    name: 'buy',
    data () {
      return {
        offerId: 0,
        offers: []
      }
    },
    beforeCreate () {
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
      getOffer: function () {
        Payment.getOfferById(this.offerId).then(tx => {
          return tx
        })
      },

      getNumberOfOffers: function () {
        return Payment.getNumberOfOffers()
      },

      getAllOffers: function (count) {
        for (let i = 1; i <= count; i++) {
          Payment.getOfferById(i).then(tx => {
            this.offers.push(tx)
          })
        }

        console.log(this.offers)
      }
    }
  }

</script>

<style scoped>

</style>
