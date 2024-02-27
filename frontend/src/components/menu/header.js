import React, { useEffect, useState, useContext } from "react";
import Breakpoint, {
  BreakpointProvider,
  setDefaultBreakpoints,
} from "react-socks";
import { header } from "react-bootstrap";
import { Link } from "@reach/router";
import useOnclickOutside from "react-cool-onclickoutside";
import { AccountContext } from "../../state/contexts/AccountContext";

import {
  useContract,
  useStarknet,
  InjectedConnector,
} from "@starknet-react/core";

setDefaultBreakpoints([{ xs: 0 }, { l: 1199 }, { xl: 1200 }]);

const NavLink = (props) => (
  <Link
    {...props}
    getProps={({ isCurrent }) => {
      // the object returned here is passed to the
      // anchor element's props
      return {
        className: isCurrent ? "active" : "non-active",
      };
    }}
  />
);

const Header = function () {
  const { account, connect } = useStarknet();
  const { setGlobalAccount } = useContext(AccountContext);

  useEffect(() => {
    if (account) {
      setGlobalAccount(account);
    }
  }, [account]);

  const disconnect = () => {
    setGlobalAccount("");
    console.log("disconnect");
    //   argentX.setConnected(false)
    //   argentX.setGlobalAccount('')
  };

  const [showmenu, btn_icon] = useState(false);
  useEffect(() => {
    const header = document.getElementById("myHeader");
    const totop = document.getElementById("scroll-to-top");
    const sticky = header.offsetTop;
    const scrollCallBack = window.addEventListener("scroll", () => {
      btn_icon(false);
      if (window.pageYOffset > sticky) {
        header.classList.add("sticky");
        totop.classList.add("show");
      } else {
        header.classList.remove("sticky");
        totop.classList.remove("show");
      }
    });
    return () => {
      window.removeEventListener("scroll", scrollCallBack);
    };
  }, []);

  return (
    <header id="myHeader" className="navbar white">
      <div className="container">
        <div className="row w-100-nav">
          <div className="logo px-0">
            <div className="navbar-title navbar-item">
              <NavLink to="/"></NavLink>
            </div>
          </div>

          <div className="search">
            <input
              id="quick_search"
              className="xs-hide"
              name="quick_search"
              placeholder="Search for items here..."
              type="text"
            />
          </div>

          <BreakpointProvider>
            <Breakpoint l down>
              {showmenu && (
                <div className="menu">
                  <div className="navbar-item">
                    <NavLink to="/home" onClick={() => btn_icon(!showmenu)}>
                      HOME
                    </NavLink>
                  </div>
                  <div className="navbar-item">
                    <NavLink to="/profile" onClick={() => btn_icon(!showmenu)}>
                      PROFILE
                    </NavLink>
                  </div>
                </div>
              )}
            </Breakpoint>

            <Breakpoint xl>
              <div className="menu">
                <div className="navbar-item">
                  <NavLink to="/activity">
                    HOME
                    <span className="lines"></span>
                  </NavLink>
                </div>

                <div className="navbar-item">
                  <NavLink to="/profile">
                    DEVELOPER
                    <span className="lines"></span>
                  </NavLink>
                </div>
                <div className="navbar-item">
                  <NavLink to="/docs">
                    DOCS
                    <span className="lines"></span>
                  </NavLink>
                </div>
              </div>
            </Breakpoint>
          </BreakpointProvider>
          <div className="mainside">
            {account && (
              <p style={{ color: "navy" }}>
                Account: {`${account.slice(0, 5)}...${account.slice(-4)}`}
              </p>
            )}
            {account ? null : (
              <button
                className="btn-main"
                onClick={() => connect(new InjectedConnector())}
                style={{ backgroundColor: "orange", color: "navy" }}
              >
                CONNECT WALLET
              </button>
            )}
          </div>
        </div>

        <button className="nav-icon" onClick={() => btn_icon(!showmenu)}>
          <div className="menu-line black"></div>
          <div className="menu-line1 white"></div>
          <div className="menu-line2 white"></div>
        </button>
      </div>
    </header>
  );
};
export default Header;
