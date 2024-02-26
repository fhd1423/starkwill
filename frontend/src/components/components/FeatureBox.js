import React from 'react';
import Reveal from 'react-awesome-reveal';
import { keyframes } from "@emotion/react";

const fadeInUp = keyframes`
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
`;

const featureBox = () => (
  <div className='row'>
    <div className="col-lg-4 col-md-6 mb-3">
      <div className="feature-box f-boxed style-3">
        <Reveal className='onStep' keyframes={fadeInUp} delay={0} duration={600} triggerOnce>
          <i className="bg-color-2 i-boxed icon_wallet"></i>
        </Reveal>
          <div className="text">
            <Reveal className='onStep' keyframes={fadeInUp} delay={100} duration={600} triggerOnce>
              <h4 className="">Connect Your Wallet</h4>
            </Reveal>
            <Reveal className='onStep' keyframes={fadeInUp} delay={200} duration={600} triggerOnce>
              <p className="">Begin your betting experience by securely connecting your digital wallet to starkBET.</p>
            </Reveal>
          </div>
          <i className="wm icon_wallet"></i>
      </div>
    </div>

    <div className="col-lg-4 col-md-6 mb-3">
      <div className="feature-box f-boxed style-3">
        <Reveal className='onStep' keyframes={fadeInUp} delay={0} duration={600} triggerOnce>
          <i className="bg-color-2 i-boxed icon_chart-bars"></i>
        </Reveal>
          <div className="text">
            <Reveal className='onStep' keyframes={fadeInUp} delay={100} duration={600} triggerOnce>
              <h4 className="">Predict Gas Fees</h4>
            </Reveal>
            <Reveal className='onStep' keyframes={fadeInUp} delay={200} duration={600} triggerOnce>
              <p className="">Make your prediction on the Ethereum gas fees and enter the amount you wish to bet.</p>
            </Reveal>
          </div>
          <i className="wm icon_chart-bars"></i>
      </div>
    </div>

    <div className="col-lg-4 col-md-6 mb-3">
      <div className="feature-box f-boxed style-3">
        <Reveal className='onStep' keyframes={fadeInUp} delay={0} duration={600} triggerOnce>
          <i className="bg-color-2 i-boxed icon_dollar"></i>
        </Reveal>
          <div className="text">
            <Reveal className='onStep' keyframes={fadeInUp} delay={100} duration={600} triggerOnce>
              <h4 className="">Place Your Bet</h4>
            </Reveal>
            <Reveal className='onStep' keyframes={fadeInUp} delay={200} duration={600} triggerOnce>
              <p className="">Enter the stake for your bet and confirm. Watch the market and see if your prediction wins!</p>
            </Reveal>
          </div>
          <i className="wm icon_dollar"></i>
      </div>
    </div>
  </div>
);

export default featureBox;