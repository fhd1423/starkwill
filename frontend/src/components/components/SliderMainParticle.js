import React from 'react';
import Reveal from 'react-awesome-reveal';
import { keyframes } from "@emotion/react";

const fadeInUp = keyframes`
  from {
    opacity: 0;
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
`;

const sliderMainParticle = () => (
  <div className="container">
    <div className="row align-items-center">
      <div className="col-md-6">
        <h6 style={{ color: 'orange', fontSize: '26px', fontWeight: 'bold' }}>
          <span className="text-uppercase">Introducing</span>
        </h6>
        <Reveal className='onStep' keyframes={fadeInUp} delay={300} duration={900} triggerOnce>
          <h1 style={{ color: 'white', fontSize: '56px', fontWeight: 'bold' }}>starkBET</h1>
        </Reveal>
        <Reveal className='onStep' keyframes={fadeInUp} delay={600} duration={900} triggerOnce>
          <p style={{ color: 'white', fontSize: '20px', fontWeight: 'bold' }}>
            Dive into the future of betting with starkBET, where you predict and bet on Stark gas fees. Connect your wallet, set your predictions, and place your bets with precision.
          </p>
        </Reveal>
        <div className="spacer-10"></div>
        <Reveal className='onStep' keyframes={fadeInUp} delay={800} duration={900} triggerOnce>
          <span onClick={()=> window.open("#", "_self")} 
                style={{ backgroundColor: 'orange', color: 'white', padding: '15px 30px', fontSize: '24px', fontWeight: 'bold', borderRadius: '5px', cursor: 'pointer' }}>
            Start Betting
          </span>
        </Reveal>
      </div>
      <div className="col-md-6 xs-hide">
        {/* Insert an appropriate image for gas fee betting */}
      </div>
    </div>
  </div>
);

export default sliderMainParticle;
